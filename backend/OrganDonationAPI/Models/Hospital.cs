namespace OrganDonationAPI.Models
{
    public class Hospital
    {
        public int Id { get; set; }
        public string UserId { get; set; } = string.Empty;
        public ApplicationUser User { get; set; } = null!;
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;

        public string LicenseNumber { get; set; } = string.Empty;
        public string Status { get; set; } = "Pending"; // Pending, Approved
        public string RejectionReason { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public bool IsApprovedByMinistry { get; set; } = false;
        public ICollection<PatientNeed> PatientNeeds { get; set; } = new List<PatientNeed>();




    }
}
