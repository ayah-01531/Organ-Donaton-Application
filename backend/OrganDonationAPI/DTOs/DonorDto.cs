namespace OrganDonationAPI.DTOs
{
    public class DonorApplicationDto
    {
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string NationalId { get; set; } = string.Empty;
        public string BloodType { get; set; } = string.Empty;
        public DateTime DateOfBirth { get; set; }
        public string Address { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public List<string> OrgansToDonat { get; set; } = new();
        public string? MedicalConditions { get; set; }  
        public string? MedicalReportsPath{get; set;} 
        }
}
