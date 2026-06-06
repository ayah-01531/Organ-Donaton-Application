using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;
using OrganDonationAPI.Data;
using OrganDonationAPI.DTOs;

namespace OrganDonationAPI.Controllers
{

    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "MinistryAdmin")]
    public class MinistryController : ControllerBase
    {
        private readonly AppDbContext _context;

        public MinistryController(AppDbContext context)
        {
            _context = context;
        }

        // ============================================================
        //  HOSPITALS
        // ============================================================

        [HttpGet("hospitals")]
        public async Task<IActionResult> GetAllHospitals()
        {
            var hospitals = await _context.Hospitals.Include(h => h.User).Select(h => new
                {
                    h.Id,
                    h.Name,
                    h.LicenseNumber,
                    h.Status,
                    h.RejectionReason,
                    Email = h.User.Email
                })
                .ToListAsync();

            return Ok(hospitals);
        }

        [HttpPut("hospitals/approve/{id}")]
        public async Task<IActionResult> ApproveHospital(int id)
        {
            var hospital = await _context.Hospitals.FindAsync(id);
            if (hospital == null) return NotFound();

            hospital.Status = "Approved";
            hospital.IsApprovedByMinistry = true;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Hospital approved." });
        }

        [HttpPut("hospitals/reject/{id}")]
        public async Task<IActionResult> RejectHospital(int id, [FromBody] ApprovalDto dto)
        {
            var hospital = await _context.Hospitals.FindAsync(id);
            if (hospital == null) return NotFound();

            if (string.IsNullOrEmpty(dto.Reason))
                return BadRequest(new { message = "Rejection reason is required." });

            hospital.Status = "Rejected";
            hospital.RejectionReason = dto.Reason;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Hospital rejected.", reason = dto.Reason });
        }

        // ============================================================
        //  DONORS
        // ============================================================

        [HttpGet("donors")]
        public async Task<IActionResult> GetAllDonors()
        {
            var donors = await _context.Donors.Include(d => d.User).Select(d => new{
                    d.Id,
                    d.NationalId,
                    d.BloodType,
                    d.Status,
                    d.RegisteredAt,
                    d.MedicalConditions,
                    d.MedicalReportsPath,
                    d.RejectionReason,
                FullName = d.User.FullName,
                    Email = d.User.Email,
                OrgansToDonat = d.OrgansToDonat
            })
                .ToListAsync();
            var result = donors.Select(d => new {
                d.Id,
                d.NationalId,
                d.BloodType,
                d.Status,
                d.RegisteredAt,
                d.MedicalConditions,
                d.MedicalReportsPath,
                d.RejectionReason,
                d.FullName,
                d.Email,
                Organs = string.IsNullOrWhiteSpace(d.OrgansToDonat)
        ? new List<string>()
        : JsonSerializer.Deserialize<List<string>>(d.OrgansToDonat)
            });

            return Ok(result);


        }

        [HttpPut("donors/approve/{id}")]
        public async Task<IActionResult> ApproveDonor(int id)
        {
            var donor = await _context.Donors.FindAsync(id);
            if (donor == null) return NotFound();

            
            if (donor.Status == "Approved")
                return BadRequest(new { message = "المتبرع معتمد مسبقاً" });

            donor.Status = "Approved";
            await _context.SaveChangesAsync();
            return Ok(new { message = "Donor approved successfully." });
        }

        [HttpPut("donors/reject/{id}")]
        public async Task<IActionResult> RejectDonor(int id, [FromBody] ApprovalDto dto)
        {
            var donor = await _context.Donors.FindAsync(id);
            if (donor == null) return NotFound();

            if (string.IsNullOrEmpty(dto.Reason))
                return BadRequest(new { message = "Rejection reason is required." });

            donor.Status = "Rejected";
            donor.RejectionReason = dto.Reason;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Donor rejected.", reason = dto.Reason });
        }
        //Dashboard stats
        [HttpGet("stats")]
        public async Task<IActionResult> GetStats()
        {
            var hospitalStats = await _context.Hospitals
                .GroupBy(h => h.Status)
                .Select(g => new { Status = g.Key, Count = g.Count() })
                .ToListAsync();

            var donorStats = await _context.Donors
                .GroupBy(d => d.Status)
                .Select(g => new { Status = g.Key, Count = g.Count() })
                .ToListAsync();

            var result = new MinistryStatsDto
            {
                Hospitals = new MinistryStatsDto.HospitalStats
                {
                    Total = hospitalStats.Sum(x => x.Count),
                    Approved = hospitalStats.FirstOrDefault(x => x.Status == "Approved")?.Count ?? 0,
                    Pending = hospitalStats.FirstOrDefault(x => x.Status == "Pending")?.Count ?? 0,
                    Rejected = hospitalStats.FirstOrDefault(x => x.Status == "Rejected")?.Count ?? 0,
                },
                Donors = new MinistryStatsDto.DonorStats
                {
                    Total = donorStats.Sum(x => x.Count),
                    Approved = donorStats.FirstOrDefault(x => x.Status == "Approved")?.Count ?? 0,
                    Pending = donorStats.FirstOrDefault(x => x.Status == "Pending")?.Count ?? 0,
                    Rejected = donorStats.FirstOrDefault(x => x.Status == "Rejected")?.Count ?? 0,
                }
            };

            return Ok(result);
        }
    }
}
