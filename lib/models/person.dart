// This class is used to handle the user' objects in the code
// After getting the information from the database a Person object is instantiated
class Person {

  String id;
  String login;
  String password;
  String name;
  String birthday;
  String bio;
  String oneId;
  bool seeWoman;
  bool seeMan;
  bool isMan;
  double lat = 0;
  double long = 0;
  List<Person> liked = [];
  List<Person> rejected = [];



  Person({required this.id, required this.name, required this.birthday,
    required this.isMan,this.login = "", this.password = "", this.seeWoman = false,
    this.seeMan = false, this.bio = "", this.oneId = ""});

}