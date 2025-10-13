class OnBoardContent {
  String image;
  String title;
  String description;
  OnBoardContent(
      {required this.description, required this.image, required this.title});
}

List<OnBoardContent> contents = [
  OnBoardContent(
      description: 'Pick your food from our menu\n          More than 35 times',
      image: "assets/images/screen1.png",
      title: 'Select from Our\n       Best Menu'),
  OnBoardContent(
      description:
          'You can pay cash on delivery and\n     Card payment is available',
      image: "assets/images/screen2.png",
      title: 'Easy and Online Payment'),
  OnBoardContent(
      description: 'Deliver your food at your\n               Doorstep',
      image: "assets/images/screen3.png",
      title: 'Quick Delivery at\n    Your Doorstep')
];
