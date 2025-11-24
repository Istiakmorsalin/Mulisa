import 'package:flutter/material.dart';

import '../../CereFlow/view/cereflow_sync.dart';
import '../../patient/view/patient_list_page.dart';
import '../../knowledgehub/knowledge_hub_screen.dart';
import '../../scheduler/view/smart_scheduler_page.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const rose = Color(0xFFF2D4D5);
    const lavender = Color(0xFFD9D0FF);
    const mint = Color(0xFFD0F5EF);
    const lemon = Color(0xFFFFF5B8);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 380;
            final crossAxisCount = isWide ? 2 : 1;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              // Ensure the column fills the viewport; if smaller, it stretches,
              // if larger, the SingleChildScrollView allows scrolling.
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // 👈 pushes grid to bottom
                  children: [
                    // ---------- TOP SECTION ----------
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFEBF2FF),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.favorite, color: Colors.redAccent, size: 22),
                              SizedBox(height: 2),
                              Text(
                                "MULISA",
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Get Started Now!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 22),
                          ],
                        ),
                      ],
                    ),

                    // ---------- BOTTOM GRID (PINNED) ----------
                    // inside LayoutBuilder -> Column (bottom section)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 100 + MediaQuery.of(context).viewPadding.bottom, // 👈 bottom gutter
                      ),
                      child:
                      GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.05,
                        children: [
                          _FeatureCard(
                            label: "Patient\nCare",
                            color: const Color(0xFFF2D4D5),
                            onTap: () {
                              Navigator.of(context).pushNamed(PatientListPage.routeName);
                            }, isActive: true,
                          ),
                          _FeatureCard(
                            label: "Knowledge\nHub",
                            color: const Color(0xFFD9D0FF),
                            isActive: true,
                            onTap: () => Navigator.of(context).pushNamed(KnowledgeHubPage.routeName),
                          ),
                          _FeatureCard(
                            label: "CereFlow\nSync",
                            color: const Color(0xFFD0F5EF),
                            isActive: true,
                            onTap: () => Navigator.of(context).pushNamed(CereFlowSyncPage.routeName),
                          ),
                          _FeatureCard(
                            label: "Smart\nScheduler",
                            color: const Color(0xFFFFF5B8),
                            isActive: true,
                            onTap: () => Navigator.of(context).pushNamed(SmartSchedulerPage.routeName),
                          ),
                        ],
                      ),

                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isActive;

  const _FeatureCard({
    required this.label,
    required this.color,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$label tapped")),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w900,
                color: isActive ? Colors.black87 : Colors.black45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

