import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MyRewardedAd {
  static void loadAdandShowAd() {
    RewardedAd? _rewardedAd;

    // TODO: replace this test ad unit with your own ad unit.
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917'
        : 'ca-app-pub-3940256099942544/1712485313';
    RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            //_rewardedAd = ad;

            ad.show(
                onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
              // Reward the user for watching an ad.
            });
          },

          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
          },
        ));
  }
}
