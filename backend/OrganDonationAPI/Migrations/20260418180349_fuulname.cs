using Microsoft.EntityFrameworkCore.Migrations;
using OrganDonationAPI.Data;

#nullable disable

namespace OrganDonationAPI.Migrations
{
    /// <inheritdoc />
    public partial class fuulname : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "FullName",
                table: "Donors",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FullName",
                table: "Donors");
        }
    }
}
