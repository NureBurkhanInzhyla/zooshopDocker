using System.ComponentModel.DataAnnotations;

namespace Zooshop.Models
{
    public class User
    {
        public int Id { get; set; }
        [Required]
        public string Name { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string? GoogleId { get; set; }
        public string? Address { get; set; }
    }
}
