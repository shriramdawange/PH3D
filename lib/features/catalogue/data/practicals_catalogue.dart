import '../../catalogue/domain/practical_definition.dart';
import '../../catalogue/domain/practical_registry.dart';
import '../../../core/ids.dart';

// Educator-review note: quantitative chemistry (concentrations, volumes,
// temperatures, yields, acceptance limits) is intentionally NOT embedded.
// Fields requiring educator review are marked REQUIRES_EDUCATOR_REVIEW in
// descriptions/instructions. Simulation outputs are labelled simulated.

PracticalRegistry buildRegistry() {
  return PracticalRegistry([
    PracticalDefinition(
      id: StableIds.chlorideTestId,
      contentVersion: '0.1.0',
      title: 'Limit Test of Chloride',
      semesterId: StableIds.semester1,
      semesterLabel: 'Semester 1',
      subjectId: StableIds.subjectInorganic,
      subjectLabel: 'Pharmaceutical Inorganic Chemistry',
      practicalType: PracticalType.analyticalTest,
      description:
          'Qualitative limit test comparing sample opalescence against a standard. '
          'REQUIRES_EDUCATOR_REVIEW: exact reagent volumes and acceptance criteria.',
      learningObjectives: const [
        'Understand the principle of chloride limit tests',
        'Perform comparison against standard (simulated)',
        'Record observations with units',
      ],
      sortOrder: 10,
      assessment: const AssessmentDefinition(
        practicalId: StableIds.chlorideTestId,
        passThreshold: 0.6,
        questions: [
          McqQuestion(
            id: 'cl_q1',
            text: 'What does a chloride limit test detect?',
            options: [
              McqOption(id: 'cl_q1_a', text: 'Chloride impurities'),
              McqOption(id: 'cl_q1_b', text: 'Blood glucose'),
              McqOption(id: 'cl_q1_c', text: 'Protein content'),
            ],
            correctOptionId: 'cl_q1_a',
            explanation: 'Limit tests detect trace chloride impurities.',
          ),
          McqQuestion(
            id: 'cl_q2',
            text: 'What is compared in a limit test?',
            options: [
              McqOption(id: 'cl_q2_a', text: 'Sample vs standard opalescence'),
              McqOption(id: 'cl_q2_b', text: 'Two different drugs'),
              McqOption(id: 'cl_q2_c', text: 'Nothing is compared'),
            ],
            correctOptionId: 'cl_q2_a',
            explanation: 'Sample turbidity is compared with a standard.',
          ),
        ],
      ),
      materials: const [
        MaterialDefinition(
          id: 'cl_sample',
          label: 'Test sample solution',
          allowedUnits: ['mL'],
        ),
        MaterialDefinition(
          id: 'cl_std_chloride',
          label: 'Standard chloride solution',
          allowedUnits: ['mL'],
        ),
        MaterialDefinition(
          id: 'cl_silver_nitrate',
          label: 'Silver nitrate reagent',
          allowedUnits: ['mL', 'drops'],
        ),
      ],
      equipment: const [
        EquipmentDefinition(id: 'cl_nessler_a', label: 'Nessler cylinder A'),
        EquipmentDefinition(id: 'cl_nessler_b', label: 'Nessler cylinder B'),
      ],
      steps: const [
        ProcedureStep(
          id: 'cl_s1',
          order: 1,
          title: 'Prepare sample',
          instruction: 'Add sample solution to Nessler cylinder A. REQUIRES_EDUCATOR_REVIEW: exact volume.',
        ),
        ProcedureStep(
          id: 'cl_s2',
          order: 2,
          title: 'Prepare standard',
          instruction: 'Add standard chloride solution to Nessler cylinder B. REQUIRES_EDUCATOR_REVIEW: exact volume.',
          prerequisites: ['cl_s1'],
        ),
        ProcedureStep(
          id: 'cl_s3',
          order: 3,
          title: 'Add reagent and compare',
          instruction: 'Add silver nitrate reagent to both cylinders and compare opalescence (simulated).',
          requiredMaterialIds: ['cl_silver_nitrate'],
          requiredEquipmentIds: ['cl_nessler_a', 'cl_nessler_b'],
          prerequisites: ['cl_s1', 'cl_s2'],
        ),
      ],
      simulation: SimulationConfig(
        practicalId: StableIds.chlorideTestId,
        kind: 'limit_test',
      ),
      scene: SceneConfig(
        practicalId: StableIds.chlorideTestId,
        rendererKind: 'temporary',
        sceneAsset: 'scenes/chloride_bench',
      ),
      reportSchema: ReportSchema(
        practicalId: StableIds.chlorideTestId,
        fields: const [
          'aim',
          'principle',
          'sample_vs_standard_observation',
          'inference',
        ],
      ),
      reviewStatus: ContentReviewStatus.requiresEducatorReview,
    ),
    PracticalDefinition(
      id: StableIds.benzocaineSynthesisId,
      contentVersion: '0.1.0',
      title: 'Benzocaine Synthesis',
      semesterId: StableIds.semester4,
      semesterLabel: 'Semester 4',
      subjectId: StableIds.subjectMedicinal,
      subjectLabel: 'Medicinal Chemistry',
      practicalType: PracticalType.synthesis,
      description:
          'Esterification practical (simulated). REQUIRES_EDUCATOR_REVIEW: reaction '
          'conditions, quantities, temperatures, yields, melting point.',
      learningObjectives: const [
        'Understand esterification principle (simulated)',
        'Follow ordered synthesis steps',
        'Record simulated observations and yield',
      ],
      sortOrder: 20,
      assessment: const AssessmentDefinition(
        practicalId: StableIds.benzocaineSynthesisId,
        passThreshold: 0.6,
        questions: [
          McqQuestion(
            id: 'bz_q1',
            text: 'Benzocaine synthesis involves which reaction type?',
            options: [
              McqOption(id: 'bz_q1_a', text: 'Esterification'),
              McqOption(id: 'bz_q1_b', text: 'Photosynthesis'),
              McqOption(id: 'bz_q1_c', text: 'Fermentation'),
            ],
            correctOptionId: 'bz_q1_a',
            explanation:
                'Benzocaine is formed via esterification (simulated lab).',
          ),
          McqQuestion(
            id: 'bz_q2',
            text: 'Why is reflux used in synthesis?',
            options: [
              McqOption(id: 'bz_q2_a', text: 'To heat without losing solvent'),
              McqOption(id: 'bz_q2_b', text: 'To cool rapidly'),
              McqOption(id: 'bz_q2_c', text: 'To add colour'),
            ],
            correctOptionId: 'bz_q2_a',
            explanation: 'Reflux allows heating while condensing vapours.',
          ),
        ],
      ),
      materials: const [
        MaterialDefinition(
          id: 'bz_paba',
          label: 'p-Aminobenzoic acid (PABA)',
          allowedUnits: ['g'],
        ),
        MaterialDefinition(
          id: 'bz_ethanol',
          label: 'Ethanol',
          allowedUnits: ['mL'],
        ),
        MaterialDefinition(
          id: 'bz_acid',
          label: 'Acid catalyst',
          allowedUnits: ['mL', 'drops'],
        ),
      ],
      equipment: const [
        EquipmentDefinition(id: 'bz_reflux', label: 'Reflux assembly'),
        EquipmentDefinition(id: 'bz_beaker', label: 'Beaker'),
      ],
      steps: const [
        ProcedureStep(
          id: 'bz_s1',
          order: 1,
          title: 'Charge reactants',
          instruction: 'Add PABA and ethanol to the flask. REQUIRES_EDUCATOR_REVIEW: exact quantities.',
        ),
        ProcedureStep(
          id: 'bz_s2',
          order: 2,
          title: 'Reflux',
          instruction: 'Heat under reflux (simulated). REQUIRES_EDUCATOR_REVIEW: time and temperature.',
          requiredEquipmentIds: ['bz_reflux'],
          prerequisites: ['bz_s1'],
        ),
        ProcedureStep(
          id: 'bz_s3',
          order: 3,
          title: 'Isolate product',
          instruction: 'Neutralise, filter and dry product (simulated). Record simulated yield.',
          prerequisites: ['bz_s1', 'bz_s2'],
        ),
      ],
      simulation: SimulationConfig(
        practicalId: StableIds.benzocaineSynthesisId,
        kind: 'synthesis',
      ),
      scene: SceneConfig(
        practicalId: StableIds.benzocaineSynthesisId,
        rendererKind: 'temporary',
        sceneAsset: 'scenes/benzocaine_bench',
      ),
      reportSchema: ReportSchema(
        practicalId: StableIds.benzocaineSynthesisId,
        fields: const [
          'aim',
          'reaction_scheme',
          'simulated_yield',
          'simulated_melting_point',
        ],
      ),
      reviewStatus: ContentReviewStatus.requiresEducatorReview,
    ),
  ]);
}
