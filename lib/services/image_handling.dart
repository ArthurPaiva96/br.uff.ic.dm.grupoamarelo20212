import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:grupoamarelo20212/models/person.dart';
import 'package:image_picker/image_picker.dart';

//Service class to handle users' profile image
class ImageHandling {

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<XFile?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<void> upload(String path, Person user) async {
    //Updates the database with the new file
    File file = File(path);
    try {
      String ref = '${user.id}profilepic.jpg';
      await storage.ref(ref).putFile(file);
    } on FirebaseException catch(e) {
      throw Exception('Erro uploading file: ${e.code}');
    }
  }

  pickAndUploadImage(Person user) async {
    XFile? file = await getImage();
    if(file != null) {
      await upload(file.path, user);
    }
  }


}
