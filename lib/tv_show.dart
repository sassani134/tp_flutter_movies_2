class TvShow {
  final int id;
  final String name;
  final String imageThumbnailPath;

  TvShow({
    required this.id,
    required this.name,
    required this.imageThumbnailPath,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'],
      name: json['name'],
      imageThumbnailPath: json['image_thumbnail_path'],
    );
  }
}
