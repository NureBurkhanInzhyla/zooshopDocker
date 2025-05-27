using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using Zooshop.Data;
using Zooshop.Models;

namespace Zooshop.Controllers
{
    [Route("/api/[controller]")]
    public class SubscriptionController : Controller
    {
        private readonly AppDbContext db;

        public SubscriptionController(AppDbContext context)
        {
            db = context; //Создаём экземпляр дб контекста для операций с бд
        }

        [HttpGet("user{id}")]
        public IActionResult GetByUser(int id)
        {
            var subscription = db.Subscriptions.Where(o => o.UserId == id).ToList();

            if (subscription == null) { return NotFound(); }
            return Ok(subscription);
        }

        [HttpPut]
        public IActionResult Update([FromBody] SubscriptionUpdateDTO dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var subscription = db.Subscriptions.FirstOrDefault(o => o.Id == dto.SubscriptionId);

            if (subscription == null)
                return NotFound("Підписка не знайдена.");

            subscription.DeliveryFrequency = dto.DeliveryFrequency;
            db.SaveChanges();

            return Ok(subscription);
        }

        [HttpPost]
        public IActionResult CreateSubscription([FromBody] Subscription subscription)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userExists = db.Users.Any(u => u.Id == subscription.UserId);
            var productExists = db.Products.Any(p => p.Id == subscription.ProductId);

            if (!userExists)
                return BadRequest("Користувача не знайдено.");

            if (!productExists)
                return BadRequest("Товар не знайдено.");

            db.Subscriptions.Add(subscription);
            db.SaveChanges();

            return Ok(subscription);
        }

        [HttpDelete("{id}")]
        public IActionResult DeleteSubscription(int id)
        {
            var subscription = db.Subscriptions.FirstOrDefault(s => s.Id == id);

            if (subscription == null)
            {
                return NotFound("Підписка не знайдена.");
            }

            db.Subscriptions.Remove(subscription);
            db.SaveChanges();

            return Ok("Підписка успішно видалена.");
        }

        public class SubscriptionUpdateDTO
        {
            [Required]
            public int SubscriptionId { get; set; }
            public int DeliveryFrequency { get; set; }
        }
    }
}
