using Microsoft.AspNetCore.Mvc;
using Zooshop.Data;
using Zooshop.Models;

namespace Zooshop.Controllers
{
    [Route("/api/[controller]")]
    public class UserController : Controller
    {
        private readonly AppDbContext db;

        public UserController(AppDbContext context)
        {
            db = context; //Создаём экземпляр дб контекста для операций с бд
        }

        [HttpGet("{Email}, {Password}")]
        public IActionResult Get(String Email, String Password)
        {
            var user = db.Users.SingleOrDefault(u => u.Email == Email && u.Password == Password);

            if (user == null) { return NotFound(); }
            return Ok(user);
        }

        [HttpPost] //Этот запрос выполняется когда уже известны все атрибуты класса, тоесть они переданы прямо
        public IActionResult Post([FromBody] User user)
        {
            if (!ModelState.IsValid) //Проверяет атрибуты Required
            {
                return BadRequest(ModelState);
            }

            var newUser = new User { Name = user.Name, Email = user.Email, 
                Password = user.Password, GoogleId = user.GoogleId, Address = user.Address };

            db.Users.Add(newUser);
            db.SaveChanges();
            return Ok(newUser);
        }

        [HttpPut]
        public ActionResult Put([FromBody] User user)
        {
            if (!ModelState.IsValid) //Проверяет атрибуты Required
            {
                return BadRequest(ModelState);
            }
            var storedUser = db.Users.SingleOrDefault(u => u.Id == user.Id);
            if (storedUser == null) { return NotFound(); }
            storedUser.Name = user.Name;
            storedUser.Email = user.Email;
            storedUser.Password = user.Password;
            storedUser.GoogleId = user.GoogleId;
            storedUser.Address = user.Address;
            db.SaveChanges();
            return Ok(storedUser);
        }
    }
}