using System.ComponentModel.DataAnnotations;

namespace Zooshop.Models
{
    public class Cart
    {
        public int Id { get; set; }
        [Required]
        public int UserId { get; set; }
        public int ProductId { get; set; }
        public int Count { get; set; }
    }
}