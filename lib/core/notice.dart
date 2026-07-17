class Notice {
  final String id;
  final String date;
  final String details;
  final String link;
  final String docLink;
  final String? docPath;

  const Notice({
    required this.id,
    required this.details,
    required this.date,
    required this.link,
    required this.docLink,
    this.docPath,
  });

  Notice copyWith({
    String? id,
    String? details,
    String? date,
    String? link,
    String? docLink,
    String? docPath,
  }) {
    return Notice(
      id: id ?? this.id,
      details: details ?? this.details,
      date: date ?? this.date,
      link: link ?? this.link,
      docLink: docLink ?? this.docLink,
      docPath: docPath ?? this.docPath,
    );
  }
}
