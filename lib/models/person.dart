class Person {

  String login;
  String password;
  String name;
  int age;
  String bio = "É importante questionar o quanto a consolidação das estruturas ainda não demonstrou convincentemente que vai participar na mudança dos níveis de motivação departamental.";
  List<Person> liked = [];
  List<Person> rejected = [];


  Person({required this.name, required this.age, this.login = "", this.password = ""});

}