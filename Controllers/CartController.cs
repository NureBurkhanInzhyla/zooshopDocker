using Microsoft.AspNetCore.Mvc;
using Zooshop.Data;
using Zooshop.Models;

namespace Zooshop.Controllers
{
    [Route("/api/[controller]")]
    public class CartController : Controller
    {
        private readonly AppDbContext db;

        public CartController(AppDbContext context)
        {
            db = context; //Создаём экземпляр дб контекста для операций с бд
        }

        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            var cart = db.Carts.Where(c => c.UserId == id).ToList();

            if (cart == null) { return NotFound(); }
            return Ok(cart);
        }

        [HttpPost] //Этот запрос выполняется когда уже известны все атрибуты класса, тоесть они переданы прямо
        public IActionResult Post([FromBody] Cart cart)
        {
            if (!ModelState.IsValid) //Проверяет атрибуты Required
            {
                return BadRequest(ModelState);
            }

            var oldCart = db.Carts.SingleOrDefault(c => c.UserId == cart.UserId && c.ProductId == cart.ProductId);

            if(oldCart == null)
            {
                var newCart = new Cart { UserId = cart.UserId, ProductId = cart.ProductId, Count = cart.Count };
                db.Carts.Add(newCart);
                db.SaveChanges();
                return Ok(newCart);
            } else
            {
                oldCart.Count = oldCart.Count + 1;
                db.SaveChanges();
                return Ok(oldCart);
            }
        }

        [HttpDelete("DeleteProduct/{userId}/{productId}")]
        public IActionResult Delete(int userId, int productId)
        {
            // Находим товар в корзине для указанного UserId и ProductId
            var cartItem = db.Carts.SingleOrDefault(c => c.UserId == userId && c.ProductId == productId);

            // Если товар не найден, возвращаем ошибку NotFound
            if (cartItem == null)
            {
                return NotFound("Товар не найден в корзине.");
            }

            // Удаляем найденный товар из корзины
            db.Carts.Remove(cartItem);
            db.SaveChanges(); // Сохраняем изменения в базе данных

            return Ok("Товар успешно удален из корзины.");
        }

        [HttpDelete("ClearCart/{userId}")]
        public IActionResult ClearCart(int userId)
        {
            // Получаем все товары из корзины для указанного UserId
            var cartItems = db.Carts.Where(c => c.UserId == userId).ToList();

            // Если корзина пуста, возвращаем ошибку NotFound
            if (!cartItems.Any())
            {
                return NotFound("Корзина пуста.");
            }

            // Удаляем все товары из корзины для этого пользователя
            db.Carts.RemoveRange(cartItems);
            db.SaveChanges(); // Сохраняем изменения в базе данных

            return Ok("Корзина успешно очищена.");
        }

        [HttpPut]
        public IActionResult UpdateQuantity([FromBody] Cart updatedCart)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var cartItem = db.Carts.SingleOrDefault(c => c.UserId == updatedCart.UserId && c.ProductId == updatedCart.ProductId);

            if (cartItem == null)
            {
                return NotFound("Товар не найден в корзине.");
            }

            cartItem.Count = updatedCart.Count;

            db.SaveChanges();
            return Ok(cartItem);
        }

    }
}