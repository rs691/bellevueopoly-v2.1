import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_rules.dart';
import '../widgets/glassmorphic_card.dart';

/// Full screen for displaying game rules and prizes
/// Generic and reusable for any game type
class RulesAndPrizesScreen extends StatefulWidget {
  final GameRules gameRules;
  final VoidCallback? onClose;

  const RulesAndPrizesScreen({
    super.key,
    required this.gameRules,
    this.onClose,
  });

  @override
  State<RulesAndPrizesScreen> createState() => _RulesAndPrizesScreenState();
}

class _RulesAndPrizesScreenState extends State<RulesAndPrizesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.gameRules.gameName,
          style: GoogleFonts.baloo2(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: widget.onClose != null
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: widget.onClose,
              )
            : const BackButton(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.baloo2(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Quick Rules', icon: Icon(Icons.speed)),
            Tab(text: 'Full Rules', icon: Icon(Icons.book)),
            Tab(text: 'Prizes', icon: Icon(Icons.emoji_events)),
            Tab(text: 'FAQs', icon: Icon(Icons.help)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuickRulesTab(),
          _buildFullRulesTab(),
          _buildPrizesTab(),
          _buildFAQsTab(),
        ],
      ),
    );
  }

  Widget _buildQuickRulesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            'Quick Rules',
            style: GoogleFonts.baloo2(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.gameRules.quickRules.isEmpty)
            _buildRulePoint(1, "Check in at participating locations."),
          if (widget.gameRules.quickRules.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: _buildRulePoint(
                2,
                "Scan QR codes to earn points instantly.",
              ),
            ),
          if (widget.gameRules.quickRules.isNotEmpty)
            ...widget.gameRules.quickRules.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRulePoint(entry.key + 1, entry.value),
              );
            }),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                'View Full Rules',
                style: GoogleFonts.baloo2(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulePoint(int number, String text) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: GoogleFonts.baloo2(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullRulesTab() {
    final fullRules = widget.gameRules.fullRules.isNotEmpty
        ? widget.gameRules.fullRules
        : _fallbackFullRules;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            'Full Rules',
            style: GoogleFonts.baloo2(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...fullRules.map((section) => _buildRuleSection(section)),
        ],
      ),
    );
  }

  Widget _buildRuleSection(RuleSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassmorphicCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: GoogleFonts.baloo2(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.description,
                style: GoogleFonts.baloo2(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              if (section.bulletPoints != null) ...[
                const SizedBox(height: 12),
                ...section.bulletPoints!.map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: GoogleFonts.baloo2(
                              fontSize: 14,
                              height: 1.4,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (section.example != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(
                        color: Colors.amber.withValues(alpha: 0.5),
                        width: 4,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example:',
                        style: GoogleFonts.baloo2(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.amber.shade100,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        section.example!,
                        style: GoogleFonts.baloo2(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrizesTab() {
    final prizes = widget.gameRules.prizes.isNotEmpty
        ? widget.gameRules.prizes
        : _fallbackPrizes;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            'Prizes & Rewards',
            style: GoogleFonts.baloo2(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...prizes.map((prize) => _buildPrizeCard(prize)),
        ],
      ),
    );
  }

  Widget _buildPrizeCard(Prize prize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(prize.icon ?? '🎁', style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prize.title,
                      style: GoogleFonts.baloo2(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prize.description,
                      style: GoogleFonts.baloo2(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    if (prize.details != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        prize.details!,
                        style: GoogleFonts.baloo2(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '+${prize.points} pts',
                  style: GoogleFonts.baloo2(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQsTab() {
    final faqs = widget.gameRules.faqs.isNotEmpty
        ? widget.gameRules.faqs
        : _fallbackFaqs;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            'Frequently Asked Questions',
            style: GoogleFonts.baloo2(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...faqs.map((faq) => _buildFAQItem(faq)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQ faq) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              faq.question,
              style: GoogleFonts.baloo2(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white70,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  faq.answer,
                  style: GoogleFonts.baloo2(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder content to keep tabs feeling full when no data is provided
final List<RuleSection> _fallbackFullRules = [
  RuleSection(
    title: 'Overview',
    description:
        'Complete challenges around town, scan proof of completion, and earn points toward weekly prizes.',
    bulletPoints: [
      'Check in at participating locations during business hours',
      'Scan posted QR codes after eligible actions to lock in points',
      'Track progress in the Game Hub and redeem prizes in the Prizes tab',
    ],
  ),
  RuleSection(
    title: 'Earning Points',
    description:
        'Every visit, scan, and challenge completion adds to your weekly total. Bonus multipliers appear on weekends.',
    bulletPoints: [
      'Daily streaks add +25% to earned points for that day',
      'Featured partners may award double points during promos',
      'Receipts must be scanned within 24 hours to qualify',
    ],
    example:
        'Example: Complete a cafe challenge (150 pts) on Saturday with a streak active (+25%) for a total of 188 pts.',
  ),
  RuleSection(
    title: 'Fair Play',
    description:
        'One account per player. Duplicate scans, tampered QR codes, or scripted submissions may be voided.',
    bulletPoints: [
      'Keep location services on during scans for validation',
      'Report damaged QR codes to support@bellevueopoly.com',
      'Staff may ask to verify your account name with an ID',
    ],
  ),
];

final List<Prize> _fallbackPrizes = [
  Prize(
    title: 'Weekly Champion',
    description: 'Top scorer wins a feature reward plus bonus points.',
    points: 500,
    icon: '🏆',
    details: 'Awarded every Monday at 9 AM.',
  ),
  Prize(
    title: 'Local Hero Bundle',
    description: 'Gift cards to neighborhood favorites and limited merch.',
    points: 350,
    icon: '🎁',
  ),
  Prize(
    title: 'Flash Drop',
    description: 'Surprise reward that appears for the first 50 redemptions.',
    points: 150,
    icon: '⚡',
  ),
];

final List<FAQ> _fallbackFaqs = [
  FAQ(
    question: 'How do I join a challenge?',
    answer:
        'Open the Game Hub, pick a challenge card, and follow the steps. You will see a scanner prompt when proof is needed.',
  ),
  FAQ(
    question: 'Why was my scan rejected?',
    answer:
        'Most rejections are due to glare or expired codes. Clean your lens, increase brightness, and rescan within the 24-hour window.',
  ),
  FAQ(
    question: 'When do points reset?',
    answer:
        'Points reset Sunday at 11:59 PM. Use them before they expire or redeem for prizes ahead of time.',
  ),
];
