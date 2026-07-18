import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apsara_wallet_mobile/shared/widgets/brand/apsara_emblem.dart';

void main() {
  testWidgets('ApsaraEmblem renders the Gilded Poise mark', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ColoredBox(
          color: Color(0xFF0B5B3D),
          child: Center(child: ApsaraEmblem(size: 300, ringTurns: 0.02)),
        ),
      ),
    );
    await expectLater(
      find.byType(ApsaraEmblem),
      matchesGoldenFile('goldens/apsara_emblem.png'),
    );
  });
}
