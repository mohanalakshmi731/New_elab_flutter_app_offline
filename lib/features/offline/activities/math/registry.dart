// Local activities copied from MathZoro 10. Only API-returned activities are displayed.
// Keys are mapping_id values from the Class X CBSE 2026 Mathematics content export.
import 'package:flutter/material.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-1/DecimalSorterApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-1/FactorSpaceAcademyApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-1/IrrationalSpiralApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-1/LCMHCFApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-1/RoyalTilerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-10/CircumscribedFortApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-10/ConcentricRingApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-10/ExternalTwinsApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-10/RadiusRadarApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-10/TangentTouchApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-11/ArcWalkerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-11/BroochMakerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-11/PizzaSlicerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-11/SegmentShaperApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-11/WiperBladeApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-12/CapsuleCoaterApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-12/ClayMoulderApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-12/EmbankmentBuilderApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-12/ToyAssemblerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-12/VolumeBuilderApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-13/MeanMachineApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-13/MedianLineApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-13/MissingFrequencyApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-13/ModalTowerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-13/OgiveTrackerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-14/CardSharkApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-14/CoinFlipperApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-14/DiceRollerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-14/MarblePickerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-14/ProbabilityScaleApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-2/CubicCoasterApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-2/DivisionMazeApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-2/ParabolaSkaterApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-2/PolynomialConstructorApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-2/ZeroesBalanceBeamApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-3/EliminationArenaApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-3/LineInterceptorApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-3/RatioAnalyserApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-3/SubstitutionDetectiveApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-3/WordProblemTranslatorApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-4/DiscriminantRadarApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-4/FactorisationApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-4/FormulaPilotApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-4/GardenArchitectApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-4/QuadraticApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-5/GaussChallengeApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-5/LadderClimberApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-5/MissingLinkApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-5/PatternSpotterApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-5/SavingsPlannerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-6/AreaRatioCutterApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-6/ShadowSurveyorApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-6/ShapeShifterApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-6/SimilarityScannerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-6/ThalesLadderApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-7/AreaSurveyorApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-7/CollinearCheckerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-7/GpsNavigatorApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-7/MidpointMeetingApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-7/SectionDividerApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-8/AngleEvaluatorApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-8/ComplementarySwitchApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-8/HeightEstimatorApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-8/RatioBuilderApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-8/SpecialAngleDialApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-9/BrokenTreeApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-9/ClinometerConstructorApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-9/RescueChopperApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-9/ShadowShifterApp.dart';
import 'package:elab_app/features/offline/activities/math/Chapter-9/TowerScalerApp.dart';

const Map<int, Widget> mathActivityWidgets = {
  // Chapter 1 Activities
  833: DecimalSorterApp(), //833 dev activity
  2257: RoyalTilerApp(),
  2259: FactorSpaceAcademyApp(),
  2260: LCMHCFApp(),
  2262: IrrationalSpiralApp(),

  // Chapter 2 Activities
  2311: ParabolaSkaterApp(),
  2316: CubicCoasterApp(),
  2317: DivisionMazeApp(),
  2314: PolynomialConstructorApp(),
  2312: ZeroesBalanceBeamApp(),

  // Chapter 3 Activities
  2325: EliminationArenaApp(),
  2319: LineInterceptorApp(),
  2321: RatioAnalyserApp(),
  2323: SubstitutionDetectiveApp(),
  2327: WordProblemTranslatorApp(),

  // Chapter 4 Activities
  2332: DiscriminantRadarApp(),
  2330: FactorisationApp(),
  2334: FormulaPilotApp(),
  2336: GardenArchitectApp(),
  2328: QuadraticApp(),

  // Chapter 5 Activities
  2342: GaussChallengeApp(),
  2339: LadderClimberApp(),
  2341: MissingLinkApp(),
  2337: PatternSpotterApp(),
  2344: SavingsPlannerApp(),

  // Chapter 6 Activities
  2346: ShapeShifterApp(),
  2348: ThalesLadderApp(),
  2350: SimilarityScannerApp(),
  2450: ShadowSurveyorApp(),
  2353: AreaRatioCutterApp(),

  // Chapter 7 Activities
  2362: AreaSurveyorApp(),
  2364: CollinearCheckerApp(),
  2356: GpsNavigatorApp(),
  2358: MidpointMeetingApp(),
  2360: SectionDividerApp(),

  // Chapter 8 Activities
  2762: AngleEvaluatorApp(),
  2248: ComplementarySwitchApp(),
  2254: HeightEstimatorApp(),
  2242: RatioBuilderApp(),
  2761: SpecialAngleDialApp(),

  // Chapter 9 Activities
  2236: BrokenTreeApp(),
  2228: ClinometerConstructorApp(),
  2233: RescueChopperApp(),
  2239: ShadowShifterApp(),
  2230: TowerScalerApp(),

  // Chapter 10 Activities
  2272: CircumscribedFortApp(),
  2270: ConcentricRingApp(),
  2268: ExternalTwinsApp(),
  2266: RadiusRadarApp(),
  2264: TangentTouchApp(),

  // Chapter 11 Activities
  2276: ArcWalkerApp(),
  2281: BroochMakerApp(),
  2274: PizzaSlicerApp(),
  2278: SegmentShaperApp(),
  2280: WiperBladeApp(),

  // Chapter 12 Activities
  2285: CapsuleCoaterApp(),
  2289: ClayMoulderApp(),
  2291: EmbankmentBuilderApp(),
  2283: ToyAssemblerApp(),
  2287: VolumeBuilderApp(),

  // Chapter 13 Activities
  2293: MeanMachineApp(),
  2296: MedianLineApp(),
  2300: MissingFrequencyApp(),
  2295: ModalTowerApp(),
  2298: OgiveTrackerApp(),

  // Chapter 14 Activities
  2306: CardSharkApp(),
  2302: CoinFlipperApp(),
  2303: DiceRollerApp(),
  2307: MarblePickerApp(),
  2309: ProbabilityScaleApp(),
};
