class GlossaryTerm {
  final String id;
  final String term;
  final String definition;
  final String simpleExample;
  final String iconName;
  final String? relatedCategory;

  const GlossaryTerm({
    required this.id,
    required this.term,
    required this.definition,
    required this.simpleExample,
    required this.iconName,
    this.relatedCategory,
  });

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) {
    return GlossaryTerm(
      id: json['id'] as String,
      term: json['term'] as String,
      definition: json['definition'] as String,
      simpleExample: json['simpleExample'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'help',
      relatedCategory: json['relatedCategory'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'term': term,
    'definition': definition,
    'simpleExample': simpleExample,
    'iconName': iconName,
    'relatedCategory': relatedCategory,
  };
}
