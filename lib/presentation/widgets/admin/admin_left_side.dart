import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';

class AdminLeftSide extends StatelessWidget {
  final String businessSlug;
  const AdminLeftSide({super.key, required this.businessSlug});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey[350]!)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.shield),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Admin Panel",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "Negocio",
                        style: GoogleFonts.getFont(FontNames.fontNameH2),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text(
                  "Dashboard",
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () {
                  context.go("/$businessSlug/admin/dashboard");
                },
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.inventory),
                title: Text(
                  "Productos",
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () {
                  context.go("/$businessSlug/admin/products");
                },
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.image),
                title: Text(
                  "Banners",
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () {
                  context.go("/$businessSlug/admin/banners");
                },
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text(
                  "Configuración",
                  style: GoogleFonts.getFont(FontNames.fontNameH2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onTap: () {
                  context.go("/$businessSlug/admin/settings");
                },
              ),
              Spacer(),
              Divider(),
              SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(child: Icon(Icons.person)),
                  SizedBox(width: 20),
                  Text(
                    "Admin",
                    style: GoogleFonts.getFont(FontNames.fontNameH2),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        context.go('/$businessSlug/admin/login');
                      }
                    },
                    icon: Icon(Icons.logout),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
