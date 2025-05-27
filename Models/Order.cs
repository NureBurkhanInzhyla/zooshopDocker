using System.ComponentModel.DataAnnotations;

namespace Zooshop.Models
{
    public class Order
    {
        public int Id { get; set; }
        [Required]
        public int OrderId { get; set; }
        public int UserId { get; set; }
        public int ProductId { get; set; }
        public string Date { get; set; }
        public string State { get; set; }
        public int Count { get; set; }
    }
}
