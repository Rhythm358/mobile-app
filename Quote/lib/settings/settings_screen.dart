import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../admob/AdaptiveBanner.dart';
import '../l10n/app_localizations.dart';
import '../style/my_button.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final screenSize = MediaQuery.of(context).size;
    final baseFontSize = screenSize.width * 0.05;

    return Scaffold(
      backgroundColor: palette.backgroundSettings,
      body: ResponsiveScreen(
        squarishMainArea: ListView(
          children: [
            SizedBox(height: screenSize.height * 0.06),
            AutoSizeText(
              AppLocalizations.of(context)!.settingsTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: baseFontSize * 2.5,
                height: 1,
              ),
              maxLines: 1,
              minFontSize: 24,
            ),
            SizedBox(height: screenSize.height * 0.06),
            _SettingsLine(
              AppLocalizations.of(context)!.privacyPolicy,
              Icons.privacy_tip,
              onSelected: () {
                launchUrl(Uri.parse(
                    'https://ss529678.stars.ne.jp/PrivacyPolicy.html'));
              },
              fontSize: baseFontSize * 1.5,
            ),
            SizedBox(height: screenSize.height * 0.035),
            _SettingsLine(
              AppLocalizations.of(context)!.credits,
              Icons.copyright,
              onSelected: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return MusicCreditsDialog();
                  },
                );
              },
              fontSize: baseFontSize * 1.5,
            ),
            SizedBox(height: screenSize.height * 0.035),
            _SettingsLine(
              AppLocalizations.of(context)!.reviewApp,
              Icons.rate_review,
              onSelected: () async {
                final InAppReview inAppReview = InAppReview.instance;

                // In-App Reviewが利用可能か確認
                if (await inAppReview.isAvailable()) {
                  await inAppReview.requestReview(); // アプリ内レビューを表示
                } else {
                  await inAppReview.openStoreListing(appStoreId: '6743759477');
                  // 6743759477 : 名言アプリ
                }
              },
              fontSize: baseFontSize * 1.5,
            ),
          ],
        ),
        rectangularMenuArea: MyButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          child: AutoSizeText(
            AppLocalizations.of(context)!.back,
            style: TextStyle(fontSize: baseFontSize),
            maxLines: 1,
            minFontSize: 14,
          ),
        ),
      ),
      bottomNavigationBar: const AdaptiveBanner(),
    );
  }
}

class _SettingsLine extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onSelected;
  final double fontSize;

  const _SettingsLine(this.title, this.icon,
      {this.onSelected, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: onSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: AutoSizeText(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Permanent Marker',
                  fontSize: fontSize,
                ),
                minFontSize: 14,
              ),
            ),
            Icon(
              icon,
              size: fontSize,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class MusicCreditsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.copyright, size: 24),
            SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.credits),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // _CreditItem(
            //   provider: 'Pocket Sound',
            //   url: 'https://pocket-se.info/',
            // ),
            // _CreditItem(
            //   provider: 'FiftySounds',
            //   url: 'https://www.fiftysounds.com',
            // ),
            // _CreditItem(
            //   provider: 'VIDEVO',
            //   url: 'https://www.videvo.net',
            // ),
            // _CreditItem(
            //   provider: '魔王魂',
            //   url: 'https://maou.audio/',
            // ),
            _CreditItem(
              provider: 'Sono - AI Music',
              url: 'https://suno.com/',
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Center(
          child: TextButton(
            child: Text(AppLocalizations.of(context)!.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}

class _CreditItem extends StatelessWidget {
  final String provider;
  final String url;

  const _CreditItem({
    required this.provider,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Provided by $provider'),
          InkWell(
            child: Text(
              url,
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
            onTap: () => launchUrl(Uri.parse(url)),
          ),
          Divider(),
        ],
      ),
    );
  }
}
