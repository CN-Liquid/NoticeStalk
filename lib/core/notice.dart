class Notice {
  final String date;
  final String details;
  final String link;
  final String docLink;
  final String? docPath;

  const Notice({
    required this.details,
    required this.date,
    required this.link,
    required this.docLink,
    this.docPath,
  });

  Notice copyWith({
    String? details,
    String? date,
    String? link,
    String? docLink,
    String? docPath,
  }) {
    return Notice(
      details: details ?? this.details,
      date: date ?? this.date,
      link: link ?? this.link,
      docLink: docLink ?? this.docLink,
      docPath: docPath ?? this.docPath,
    );
  }
}
