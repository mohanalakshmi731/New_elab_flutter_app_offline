// Class 8 source mappings; only authorized API activities are displayed.
import 'package:elab_app/features/offline/activities/class8/math/Chapter-11/EulerFormulaLabApp.dart';
import 'package:elab_app/features/offline/activities/class8/math/Chapter-11/NetsLabApp.dart';
import 'package:elab_app/features/offline/activities/class8/math/Chapter-11/PrismsVsPyramidsLabApp.dart';
import 'package:elab_app/features/offline/activities/class8/math/Chapter-11/VisualisingSectionsLabApp.dart';
import 'package:elab_app/features/offline/activities/class8/math/Chapter-12/Histograms.dart';
import 'package:elab_app/features/offline/activities/class8/math/Chapter-12/MeanAndMedian.dart';
import 'package:elab_app/features/offline/activities/class8/math/Chapter-12/OrganizingData.dart';
import 'package:elab_app/features/offline/activities/class8/math/Chapter-12/PieCharts.dart';
import 'package:elab_app/features/offline/activities/class8/math/Chapter-12/RealLifeProbability.dart';
import 'package:elab_app/features/offline/activities/class8/math/Chapter-12/VisualisingData.dart';
import 'package:elab_app/features/offline/activities/class8/math/Chapter-14/Triangles.dart';
import 'package:elab_app/features/offline/activities/class8/math/Chapter-4/AngleSumPropertyLab.dart';
import 'package:flutter/material.dart';
import 'Chapter-1/CubeRootsLab.dart';
import 'Chapter-1/CubicNumbersLab.dart';
import 'Chapter-1/PropertiesOfSquaresLab.dart';
import 'Chapter-1/SquareRootsLab.dart';
import 'Chapter-1/SquareNumbersLab.dart';
import 'Chapter-2/DivisionExponentsLab.dart';
import 'Chapter-2/ExponentialGrowthLab.dart';
import 'Chapter-2/LawsOfExponentsLab.dart';
import 'Chapter-2/ScientificNotationLab.dart';
import 'Chapter-2/Cl8M-Ch2-A1-Exponent-Builder.dart';
import 'Chapter-3/EarlyCountingLab.dart';
import 'Chapter-3/GroupingNumeralsLab.dart';
import 'Chapter-3/PositionalPlaceValueScreen.dart';
import 'Chapter-3/IdeaOfBaseLab.dart';
import 'Chapter-3/IndianSystemLab.dart';
import 'Chapter-4/KiteTrapeziumsLab.dart';
import 'Chapter-4/ParallelogramsLab.dart';
import 'Chapter-4/RectanglesSquaresLab.dart';
import 'Chapter-4/RhombusLab.dart';
import 'Chapter-5/DivisibilityLogicLab.dart';
import 'Chapter-5/ModularArithmeticLab.dart';
import 'Chapter-5/DivisibilityProofsLab.dart';
import 'Chapter-5/Cl8M-Ch5-A2-Cryptarithm-Cracker.dart';
import 'Chapter-5/Cl8M-Ch5-A3-Digit-Detective.dart';
import 'Chapter-6/GeneralisedDistributivityLab.dart';
import 'Chapter-6/IncrementsInProductsLab.dart';
import 'Chapter-6/PolynomialsLikeTermsLab.dart';
import 'Chapter-6/Cl8MCh6A4SquareBuilderIdentities.dart';
import 'Chapter-6/Cl8M-Ch6-A5-Difference-of-Squares.dart';
import 'Chapter-7/InverseVariationLab.dart';
import 'Chapter-7/RatiosProportionsLab.dart';
import 'Chapter-7/UnitaryMethodLab.dart';
import 'Chapter-7/UnequalSharingLab.dart';
import 'Chapter-7/UnitConversionsLab.dart';
import 'Chapter-7/VisualSimilarityRatiosLab.dart';
import 'Chapter-8/ComparingProportionsLab.dart';
import 'Chapter-8/FinancialLiteracyLab.dart';
import 'Chapter-8/GrowthCompoundingLab.dart';
import 'Chapter-8/PercentageChangeErrorLab.dart';
import 'Chapter-8/PercentageQuantityEstimationLab.dart';
import 'Chapter-8/TrickyPercentagesLab.dart';
import 'Chapter-9/ApplicationsInRealLifeApp.dart';
import 'Chapter-9/BaudhayanaLabApp.dart';
import 'Chapter-9/IrrationalNumbersLabApp.dart';
import 'Chapter-9/PythagorasLabApp.dart';
import 'Chapter-9/Cl8MCh9A1HalvingDoublingASquare.dart';
import 'Chapter-10/InverseProportionLabApp.dart';
import 'Chapter-10/PieChartsLabApp.dart';
import 'Chapter-10/SharingRatiosLabApp.dart';
import 'Chapter-10/UnitConversionLabApp.dart';
import 'Chapter-10/Cl8MCh10A1DirectProportionLab.dart';
import 'Chapter-13/NumberPyramids.dart';
import 'Chapter-13/FunWithGrids.dart';
import 'Chapter-13/AlgebraGrids.dart';
import 'Chapter-13/DecodingDivisibility.dart';
import 'Chapter-14/RectanglesAndSquares.dart';
import 'Chapter-14/PerimeterAndArea.dart';
import 'Chapter-14/AreaOfAnyPolygon.dart';
import 'Chapter-14/Parallelogram.dart';
import 'Chapter-14/Rhombus.dart';
import 'Chapter-14/AreaofTrapezium.dart';

const Map<int, Widget> class8MathActivityWidgets = {
  // Chapter 1 Activities
  2661: CubeRootsLab(),
  2662: CubicNumbersLab(),
  2663: PropertiesOfSquaresLab(),
  2664: SquareRootsLab(),
  2665: SquareNumbersLab(),

  // Chapter 2 Activities
  2666: DivisionExponentsLab(),
  2667: ExponentialGrowthLab(),
  2668: LawsOfExponentsLab(),
  2669: ScientificNotationLab(),
  4070: ExponentBuilder(),

  // Chapter 3 Activities
  2670: EarlyCountingLab(),
  2671: GroupingNumeralsLab(),
  2672: PositionalPlaceValueScreen(),
  2673: IdeaOfBaseLab(),
  2674: IndianSystemLab(),

  // Chapter 4 Activities
  2675: AngleSumPropertyLab(),
  2676: KiteTrapeziumsLab(),
  2677: ParallelogramsLab(),
  2678: RectanglesSquaresLab(),
  2679: RhombusLab(),

  // Chapter 5 Activities
  2680: DivisibilityLogicLab(),
  2681: ModularArithmeticLab(),
  2682: DivisibilityProofsLab(),
  4071: CryptarithmCracker(),
  4072: DigitDetectiveApp(),

  // Chapter 6 Activities
  2683: GeneralisedDistributivityLab(),
  2684: IncrementsInProductsLab(),
  2685: PolynomialsLikeTermsLab(),
  4073: Cl8MCh6A4SquareBuilderIdentities(),
  4074: DifferenceOfSquares(),

  // Chapter 7 Activities
  2686: InverseVariationLab(),
  2687: RatiosProportionsLab(),
  2688: UnitaryMethodLab(),
  2689: UnequalSharingLab(),
  2690: UnitConversionsLab(),
  2691: VisualSimilarityRatiosLab(),

  // Chapter 8 Activities
  2692: ComparingProportionsLab(),
  2693: FinancialLiteracyLab(),
  2694: GrowthCompoundingLab(),
  2695: PercentageChangeErrorLab(),
  2696: PercentageQuantityEstimationLab(),
  2697: TrickyPercentagesLab(),

  // Chapter 9 Activities
  2698: ApplicationsInRealLifeApp(),
  2699: BaudhayanaLabApp(),
  2700: IrrationalNumbersLabApp(),
  2701: PythagorasLabApp(),
  4076: Cl8MCh9A1HalvingDoublingASquare(),

  // Chapter 10 Activities
  2702: InverseProportionLab(),
  2703: PieChartsLab(),
  2704: UnequalRatiosLab(),
  2705: UnitConversion(),
  4077: Cl8MCh10A1DirectProportionLab(),

  // Chapter 11 Activities
  2706: EulerLabScreen(),
  2707: PrismsPyramidsScreen(),
  2708: NetsLabScreen(),
  2709: VisualisingSections(),
  2710: VisualisingSections(),

  // Chapter 12 Activities
  4133: HistogramsActivity(),
  4134: OrganizingDataActivity(),
  4135: PieChartsActivity(),
  4136: RealLifeProbabilityActivity(),
  4137: MeanAndMedianActivity(),
  4138: Cl8MCh12A6VisualisingData(),

  // Chapter 13 Activities
  4139: NumberPyramidsActivity(),
  4140: FunWithGridsActivity(),
  4141: AlgebraGridsActivity(),
  4142: DecodingDivisibility(),

  // Chapter 14 Activities
  4078: TriangleAreaApp(),
  4143: RectanglesAndSquaresActivity(),
  4144: PerimeterAndAreaApp(),
  4145: AreaOfAnyPolygonApp(),
  4146: ParallelogramShearApp(),
  4147: RhombusDiagonalsApp(),
  4148: AreaOfTrapeziumApp(),
};
