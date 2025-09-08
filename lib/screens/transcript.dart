class Transcript {
  String title;
  String content;
  String date;

  Transcript({
    required this.title,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    "title": title,
    "content": content,
    "date": date,
  };

  factory Transcript.fromJson(Map<String, dynamic> json) => Transcript(
    title: json["title"],
    content: json["content"],
    date: json["date"],
  );
}
