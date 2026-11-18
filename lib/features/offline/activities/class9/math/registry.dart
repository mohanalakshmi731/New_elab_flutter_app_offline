// Class 9 mapping IDs from the source app; only authorized API activities are displayed.
import 'package:elab_app/features/offline/activities/class9/math/Chapter-1/CoordinateScoutApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-1/GridBuilderApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-1/PrecisionPlotterApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-1/QuadrantCommanderApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-1/ShapeShifterApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-2/EquationBalancerApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-2/LaserLineApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-2/PolySorterApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-2/SolutionGeneratorApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-2/WallBuilderApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-2/ZeroGravityGame.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-2/CricketScorerApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-3/DecimalDecoderGame.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-3/NanoLensGame.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-3/NumberVaultGame.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-3/PowerTowerGame.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-3/SpiralArchitectGame.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-4/CubeConstructor.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-4/FactoriseWithAlgebraTiles.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-4/IdentityArchitect.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-4/IdentityCrisisApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-4/MinusMattersRemovalSquare.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-4/SplitTheMiddleFactorQuadratics.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-4/TheCubicVaultApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-4/TileArchitectScreen.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-4/TrinomialTrioGrid.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-5/AngleSpotlightApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-5/CyclicShieldApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-5/EqualizerApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-5/PerpendicularCutterApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-5/SemiCircleSniperApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-6/FieldDividerApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-6/HeightHunterApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-6/PerimeterPatrolApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-6/RatioScalerApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-6/TrianglePainterApp.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-7/BranchingOutTreeDiagramChallenge.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-7/Chance-explorer-predict-the-odds.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-7/Event-ranking-rally.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-7/OutcomeOrganizerSampleSpaceBuilder.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-7/Trial-tester-dice-and-coin-quest.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-8/FormulaFactoryComputeAndVerifyTerms.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-8/MathMissionTermNotationAndSequencePrediction.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-8/Pattern-explorer-identify-and-predict-sequence-terms.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-8/PatternQuestCheckingSequenceMembershipViaExplicitFormula.dart';
import 'package:elab_app/features/offline/activities/class9/math/Chapter-8/PatternQuestExplicitRulesForSequencesPracticeRound.dart';
import 'package:flutter/material.dart';

const Map<int, Widget> class9MathActivityWidgets = {
  // Chapter 1 Activities
  3945: GridBuilderApp(),
  3977: CoordinateScoutApp(),
  3978: QuadraticCommanderApp(),
  3979: PrecisionPlotterScreen(),
  3980: ShapeShifterScreen(),

  // Chapter 2 Activities
  3950: ZeroGravityGame(),
  3952: EquationBalancerScreen(),
  3981: PolySorterScreen(),
  3982: SolutionGeneratorScreen(),
  3983: LaserLineScreen(),
  3984: WallBuilderScreen(),
  3985: CricketScorerScreen(),

  // Chapter 3 Activities
  3986: NumberVaultGame(),
  3987: DecimalDecoderGame(),
  3988: SpiralArchitectGame(),
  3989: NanoLensGame(),
  4063: PowerTowerGame(),

  // Chapter 4 Activities
  3990: TileArchitectScreen(),
  3991: IdentityCrisisScreen(),
  3992: TheCubicVaultScreen(),
  4064: IdentityArchitect(),
  4065: MinusMattersRemovalSquare(),
  4066: TrinomialTrioGrid(),
  4067: FactoriseWithAlgebraTiles(),
  4068: SplitTheMiddleFactorQuadratics(),
  4069: CubeConstructor(),

  // Chapter 5 Activities
  3993: AngleSpotlightApp(),
  3994: PerpendicularCutterScreen(),
  3995: CyclicShieldApp(),
  3996: EqualizerApp(),
  3997: SemiCircleSniperApp(),

  // Chapter 6 Activities
  3998: HeightHunterScreen(),
  3999: PerimeterPatrolApp(),
  4000: RatioScalerScreen(),
  4001: FieldDividerScreen(),
  4002: TrianglePainterScreen(),

  // Chapter 7 Activities
  4003: ChanceExplorerPredictOdds(),
  4004: OutcomeOrganizerSampleSpaceBuilder(),
  4005: EventRankingRallyApp(),
  4006: TrialTesterApp(),
  4007: BranchingOutTreeDiagramChallenge(),

  // Chapter 8 Activities
  4008: PatternExplorerIdentifyAndPredict(),
  4009: FormulaFactoryComputeAndVerifyTerms(),
  4010: MathMissionTermNotationAndSequencePrediction(),
  4011: PatternQuestCheckingSequenceMembershipViaExplicitFormula(),
  4012: PatternQuestExplicitRulesForSequencesPracticeRound(),
};
