import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/screens/news_item.dart';
import 'package:flutter/material.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List news = [
    {
      "title":
          "Haryana Government’s Ban On “Stilt Plus Four Floors” Construction",
      "dateTime": "Mar 2, 2023 02:11 PM",
      "source": "Online News",
      "description":
          "On 22 February 2023, Chief minister of Haryana, Manohar Lal Khattar announced in the state assembly that the state government will not entertain new applications or building plan maps for stilt plus four-storey structures. \n\nRead More....",
      "link":
          "https://swarajyamag.com/infrastructure/haryana-governments-ban-on-stilt-plus-four-floors-construction-what-it-means-for-gurugrams-thriving-plotted-residential-developments",
      "postedBy": "Admin"
    },
    {
      "title": "Huda to slash reserve price for school sites",
      "dateTime": "Jan 12, 2023, 5:30 PM",
      "source": "Indiatimes.com",
      "description":
          "GURUGRAM: Huda is planning to slash the reserve price for school sites. Sources said the development authority had been unable to sell any plot earmarked for setting up schools in the past one-and-a-half years due to a high reserve price. \n\nRead More....",
      "link":
          "https://timesofindia.indiatimes.com/city/gurgaon/huda-to-slash-reserve-price-for-school-sites/articleshow/63152521.cms",
      "postedBy": "Admin"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("News & Updates",
            style: TextStyle(color: AppColors.screenTitleColor, fontSize: 16)),
        elevation: 1,
        centerTitle: true,
        actions: <Widget>[],
      ),
      body: Container(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 0),
          itemCount: news.length,
          itemBuilder: (BuildContext context, int index) {
            Map newsItem = news[index];
            return NewsItem(
              title: newsItem["title"],
              dateTime: newsItem["dateTime"],
              source: newsItem["source"],
              description: newsItem["description"],
              link: newsItem["link"],
              postedBy: newsItem["postedBy"],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
        ),
        onPressed: () {},
      ),
    );
  }
}
