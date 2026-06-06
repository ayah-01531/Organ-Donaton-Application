using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Mvc;
using OrganDonationAPI.Data;
using OrganDonationAPI.DTOs;
using OrganDonationAPI.Models;

namespace OrganDonationAPI.Controllers
{
    

    [ApiController]
    [Route("api/[controller]")]
    public class DeceasedController : ControllerBase
    {
        private readonly AppDbContext _context;

        public DeceasedController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("verify")]
        public async Task<IActionResult> Verify([FromBody] string nationalId)
        {
            var donor = await _context.DonorRequests
                .FirstOrDefaultAsync(d => d.NationalId == nationalId
                                       && d.Status == "Approved");

            if (donor == null)
                return Ok(new { isRegisteredDonor = false });

            return Ok(new
            {
                isRegisteredDonor = true,
                donorName = donor.FullName,
                organs = donor.OrgansToDonat,
                bloodType = donor.BloodType
            });
        }

        [HttpPost]
        public async Task<IActionResult> RegisterDeath([FromBody] DeceasedDtos dto)
        {
            var hospitalId = int.Parse(User.FindFirst("hospitalId")!.Value);

            var deceased = new DeceasedPatient
            {
                NationalId = dto.NationalId,
                FullName = dto.FullName,
                DateOfDeath = dto.DateOfDeath,
                WasRegisteredDonor = dto.WasRegisteredDonor,
                AvailableOrgans = dto.AvailableOrgans,
                HospitalId = hospitalId
            };

            _context.DeceasedPatients.Add(deceased);
            await _context.SaveChangesAsync();
            return Ok(deceased);
        }
    }
}
