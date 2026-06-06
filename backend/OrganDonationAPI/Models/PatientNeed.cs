namespace OrganDonationAPI.Models
{
    public class PatientNeed
    {
        public int Id { get; set; }
        public string PatientName { get; set; } = string.Empty;
        public string NationalId { get; set; } = string.Empty;
        public string NeededOrgan { get; set; } = string.Empty;
        public string BloodType { get; set; } = string.Empty;
        public string Status { get; set; } = "Waiting"; // Waiting / Matched / Done
        public DateTime RegisteredAt { get; set; } = DateTime.UtcNow;

        // Foreign Key
        public int HospitalId { get; set; }

        public Hospital Hospital { get; set; } = null!;
    }
}
