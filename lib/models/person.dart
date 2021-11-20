class Person {

  String id;
  String login;
  String password;
  String name;
  int age;
  String bio;
  bool seeWoman;
  bool seeMan;
  List<Person> liked = [];
  List<Person> rejected = [];


  Person({required this.id, required this.name, required this.age, this.login = "",
    this.password = "", this.seeWoman = false, this.seeMan = false, this.bio = ""});

}