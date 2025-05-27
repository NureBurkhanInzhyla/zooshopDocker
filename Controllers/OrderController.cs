using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using Zooshop.Data;
using Zooshop.Models;

namespace Zooshop.Controllers
{
    [Route("/api/[controller]")]
    public class OrderController : Controller
    {
        private readonly AppDbContext db;

        public OrderController(AppDbContext context)
        {
            db = context; //Создаём экземпляр дб контекста для операций с бд
        }

        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            var order = db.Orders.Where(o => o.OrderId == id).ToList();

            if (order == null) { return NotFound(); }
            return Ok(order);
        }

        [HttpGet("user{id}")]
        public IActionResult GetByUser(int id)
        {
            var order = db.Orders.Where(o => o.UserId == id).ToList();

            if (order == null) { return NotFound(); }
            return Ok(order);
        }

        [HttpPost]
        public IActionResult CreateOrder([FromBody] OrderDTO order)
        {
            int userId = order.UserId;

            // Получаем все товары из корзины для указанного пользователя
            var cartItems = db.Carts.Where(c => c.UserId == userId).ToList();

            if (!cartItems.Any())
            {
                return BadRequest("Корзина пуста.");
            }

            // Получаем последний OrderId для данного пользователя (если есть)
            var lastOrder = db.Orders.Where(o => o.UserId == userId).OrderByDescending(o => o.OrderId).FirstOrDefault();

            // Если заказов нет, то OrderId будет 1, иначе увеличиваем на 1
            int orderId = lastOrder != null ? lastOrder.OrderId + 1 : 1;

            var currentDate = DateTime.Now.ToString("yyyy-MM-dd");
            var state = "Не оплачен";

            // Создаем список заказов для всех товаров в корзине
            var orders = cartItems.Select(cartItem => new Order
            {
                OrderId = orderId, // Генерируем OrderId вручную, увеличиваем на 1 для каждого заказа
                UserId = cartItem.UserId,
                ProductId = cartItem.ProductId,
                Date = currentDate,
                State = state,
                Count = cartItem.Count
            }).ToList();

            // Добавляем заказы в базу данных
            db.Orders.AddRange(orders);
            db.SaveChanges();

            return Ok(orders); // Возвращаем список созданных заказов
        }

        [HttpPut]
        public IActionResult Update([FromBody] OrderUpdateDTO orderUpdateDTO)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var orderList = db.Orders.Where(o => o.OrderId == orderUpdateDTO.OrderId).ToList();

            if (!orderList.Any())
            {
                return NotFound("Заказ не найден.");
            }

            foreach (var order in orderList)
            {
                order.State = orderUpdateDTO.State; // Устанавливаем новое значение для поля State
            }

            db.SaveChanges();
            return Ok(orderList);
        }
    }

    public class OrderDTO
    {
        [Required]
        public int UserId { get; set; }
    }

    public class OrderUpdateDTO
    {
        [Required]
        public int OrderId { get; set; }
        public string State { get; set; }
    }
}
