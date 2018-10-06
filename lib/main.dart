import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

void main() => runApp(AreaAndLineChart());

class AreaAndLineChart extends StatelessWidget {
  AreaAndLineChart();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.amber[700],
            accentColor: Colors.lightBlueAccent[200]),
        home: SamplePage());
  }
}

class CultivationDataSeries {
  final DateTime timestamp;
  int tones;

  CultivationDataSeries(this.timestamp, this.tones);
}

class SamplePage extends StatefulWidget {
  final String title;

  SamplePage({Key key, this.title}) : super(key: key);

  @override
  _InternalState createState() => _InternalState();
}

class _InternalState extends State<SamplePage> {
  _InternalState();

  var _captionIndex = 0;

  static final _data = [
    new CultivationDataSeries(DateTime.utc(2018, 9, 1), -12),
    new CultivationDataSeries(DateTime.utc(2018, 9, 2), 42),
    new CultivationDataSeries(DateTime.utc(2018, 9, 3), 23),
    new CultivationDataSeries(DateTime.utc(2018, 9, 4), -1),
    new CultivationDataSeries(DateTime.utc(2018, 9, 5), 0),
    new CultivationDataSeries(DateTime.utc(2018, 9, 6), 0),
    new CultivationDataSeries(DateTime.utc(2018, 9, 7), 2),
    new CultivationDataSeries(DateTime.utc(2018, 9, 15), -12),
    new CultivationDataSeries(DateTime.utc(2018, 9, 23), 14),
    new CultivationDataSeries(DateTime.utc(2018, 9, 26), -50),
    new CultivationDataSeries(DateTime.utc(2018, 9, 30), -40),
    new CultivationDataSeries(DateTime.utc(2018, 10, 3), 51),
    new CultivationDataSeries(DateTime.utc(2018, 10, 11), 1),
    new CultivationDataSeries(DateTime.utc(2018, 10, 12), 4),
    new CultivationDataSeries(DateTime.utc(2018, 10, 17), 3),
    new CultivationDataSeries(DateTime.utc(2018, 10, 19), 12),
    new CultivationDataSeries(DateTime.utc(2019, 1, 2), 15),
    new CultivationDataSeries(DateTime.utc(2019, 1, 3), 16),
    new CultivationDataSeries(DateTime.utc(2019, 1, 11), 12),
    new CultivationDataSeries(DateTime.utc(2019, 1, 12), -10),
    new CultivationDataSeries(DateTime.utc(2019, 1, 13), -22),
    new CultivationDataSeries(DateTime.utc(2019, 1, 14), 21),
    new CultivationDataSeries(DateTime.utc(2019, 1, 15), 20),
    new CultivationDataSeries(DateTime.utc(2019, 1, 16), 22),
  ];

  @override
  Widget build(BuildContext context) {
    
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Chart Sample"),
            bottom: TabBar(tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
              Tab(text: 'Annually')
            ]),
          ),
          body: TabBarView(
            children: [
              DailyTrendsWidget(_data),
              WeeklyTrendsWidget(_data),
              MonthlyTrendsWidget(_data),
              AnuallyTrendsWidget(_data)
            ]
          ),
        ));
  }
}

class DailyTrendsWidget extends StatefulWidget {

  final List<CultivationDataSeries> trends;

  DailyTrendsWidget(this.trends);

  @override
  DailyTrendsState createState() => DailyTrendsState(this.trends);
}

class WeeklyTrendsWidget extends StatefulWidget {
  final List<CultivationDataSeries> trends;

  WeeklyTrendsWidget(this.trends);

  @override
  WeeklyTrendsState createState() => WeeklyTrendsState(this.trends);
}

class MonthlyTrendsWidget extends StatefulWidget {
  final List<CultivationDataSeries> trends;

  MonthlyTrendsWidget(this.trends);

  @override
  MonthlyTrendsState createState() => MonthlyTrendsState(trends);
}

class AnuallyTrendsWidget extends StatefulWidget {
  final List<CultivationDataSeries> trends;

  AnuallyTrendsWidget(this.trends);

  @override
  AnuallyTrendsState createState() => AnuallyTrendsState(trends);
}

abstract class AbstractTrendsBehavior {

  categorize(List<CultivationDataSeries> data);

  getSeries(List<CultivationDataSeries> trends)  {
    return [
      new charts.Series<CultivationDataSeries, DateTime>(
        domainFn: (CultivationDataSeries d, _) => d.timestamp,
        measureFn: (CultivationDataSeries d, _) => d.tones,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        id: 'Cultivations',
        data: categorize(trends),
      )..setAttribute(charts.rendererIdKey, 'customArea'),
    ];
  }

  createChartWidget(List<CultivationDataSeries> data) {
    var chart = new charts.TimeSeriesChart(getSeries(data),
      animate: true,
      customSeriesRenderers: [
        new charts.LineRendererConfig(
          // ID used to link series to this renderer.
          customRendererId: 'customArea',
          includeArea: true,
          stacked: true),
    ]);

    return Padding(
      padding: new EdgeInsets.all(32.0),
      child: new SizedBox(
        height: 200.0,
        child: chart,
      ),
    );
  }
}

class DailyTrendsState extends
  State<DailyTrendsWidget> with AbstractTrendsBehavior {

  final List<CultivationDataSeries> trends;

  DailyTrendsState(this.trends);

  @override
  categorize(List<CultivationDataSeries> data) {
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          createChartWidget(this.trends),
          Text('Daily Trends')
      ]));
  }
}

class WeeklyTrendsState extends
  State<WeeklyTrendsWidget> with AbstractTrendsBehavior {

  final List<CultivationDataSeries> trends;

  WeeklyTrendsState(this.trends);

  

  @override
  categorize(List<CultivationDataSeries> data) {
    
    // generate dates starting from the first date of the year
    var firstThursday = DateTime.utc(2018, DateTime.january, 1);

    if (firstThursday.weekday != DateTime.thursday) {
      firstThursday = DateTime.utc(2018, DateTime.january, 1 + ((4 - firstThursday.weekday) + 7) % 7);
    }

    getWeekForNumberForDate(DateTime date) {
      int today = date.weekday;
      // ISO weekdays starts on monday so correct the day number
      var dayNr = (today + 6) % 7;

      // ISO states that week 1 is the week with the first thursday
      // of that year
      // set the target date to the thursday in the target week
      var targetMonday = date.subtract(Duration(days: dayNr));
      var targetThursday = targetMonday.add(Duration(days: 3));

      // the week number is the number of weeks between the
      // first thursday of the year and the target thursday in the week
      var x = targetThursday.millisecondsSinceEpoch - firstThursday.millisecondsSinceEpoch;
      return x.ceil() ~/ 604800000;
    }

    List<CultivationDataSeries> acc = List.generate(52, (int index) {
      return CultivationDataSeries(firstThursday.add(Duration(days: index * 7)), 0);
    });

    data.forEach((el) {
      // retrieve corresponding week item
      int index = getWeekForNumberForDate(el.timestamp);
      if (index > 51) {
        return;
      }
      acc[index].tones += el.tones;
    });

    // aggregate data into weeks
    print(getWeekForNumberForDate(acc.last.timestamp));

    return acc;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          createChartWidget(this.trends),
          Text('Weekly Trends: 2018')
      ]));
  }
}

class MonthlyTrendsState extends
  State<MonthlyTrendsWidget> with AbstractTrendsBehavior {

  final List<CultivationDataSeries> trends;

  MonthlyTrendsState(this.trends);

  @override
  categorize(List<CultivationDataSeries> data) {
    // aggregate data for the current year by months
    List<CultivationDataSeries> acc = List.generate(12, (int index) {
      print(index);
      return CultivationDataSeries(DateTime(2018, index + 1, 1), 0);
    });

    // iterate data and accumulate wherever possible
    data.forEach((point) =>
      acc[point.timestamp.month - 1].tones += point.tones);

    return acc;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          createChartWidget(this.trends),
          Text('Monthly Trends')
      ]));
  }
}

class AnuallyTrendsState extends
  State<AnuallyTrendsWidget> with AbstractTrendsBehavior {

  final List<CultivationDataSeries> trends;

  AnuallyTrendsState(this.trends);

  @override
  categorize(List<CultivationDataSeries> data) {

    // aggregate for the same year
    List<CultivationDataSeries> acc =
      List.generate(2, (int index) {
        return CultivationDataSeries(DateTime.utc(2018 + index, DateTime.january, 1), 0);
      });

    // aggregate data between the two years
    data.forEach((e) {
      acc[e.timestamp.year == 2018 ? 0 : 1].tones += e.tones;
    });

    return acc;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          createChartWidget(this.trends),
          Text('Annual Trends (2018 - 2019)')
      ]));
  }
}
