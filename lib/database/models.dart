class DocumentModel {
  final int? docId;
  final String fileName;
  final String filePath;
  final int fileSizeKb;
  final int totalPages;

  DocumentModel({
    this.docId,
    required this.fileName,
    required this.filePath,
    required this.fileSizeKb,
    required this.totalPages,
  });

  // Convert a Document into a Map to insert into SQL
  Map<String, dynamic> toMap() {
    return {
      'doc_id': docId,
      'file_name': fileName,
      'file_path': filePath,
      'file_size_kb': fileSizeKb,
      'total_pages': totalPages,
    };
  }
}
