import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_101/models/cultivation-data-series.dart';
import 'package:flutter_101/util/Fixtures.dart';

void main() => runApp(AreaAndLineChart());

class AreaAndLineChart extends StatelessWidget {
  AreaAndLineChart();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.amber[700],
            accentColor: Colors.lightGreenAccent[200]),
        home: SamplePage());
  }
}

class SamplePage extends StatefulWidget {
  final String title;

  SamplePage({Key key, this.title}) : super(key: key);

  @override
  _InternalState createState() => _InternalState();
}

class _InternalState extends State<SamplePage> {

  /* todo: use appropiate lifecycle method to fetch data from
    an external source*/
  _InternalState(): this._data = Fixtures.data;

  // library private data
  final List<CultivationDataSeries> _data;

  // build the widget
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
              AnualTrendsWidget(_data)
            ]
          ),
        ));
  }
}

// widget to display daily trends
class DailyTrendsWidget extends StatefulWidget {

  final List<CultivationDataSeries> data;

  DailyTrendsWidget(this.data);

  @override
  DailyTrendsState createState() => DailyTrendsState(this.data);
}

class WeeklyTrendsWidget extends StatefulWidget {
  final List<CultivationDataSeries> data;

  WeeklyTrendsWidget(this.data);

  @override
  WeeklyTrendsState createState() => WeeklyTrendsState(this.data);
}

class MonthlyTrendsWidget extends StatefulWidget {
  final List<CultivationDataSeries> trends;

  MonthlyTrendsWidget(this.trends);

  @override
  MonthlyTrendsState createState() => MonthlyTrendsState(trends);
}

class AnualTrendsWidget extends StatefulWidget {
  final List<CultivationDataSeries> trends;

  AnualTrendsWidget(this.trends);

  @override
  AnualTrendsState createState() => AnualTrendsState(trends);
}

abstract class AbstractTSChartState<T extends StatefulWidget> extends State<T> {

  final List<CultivationDataSeries> data;
  final String caption;

  AbstractTSChartState(this.data, this.caption);

  categorize(List<CultivationDataSeries> data);

  getSeries(List<CultivationDataSeries> trends)  {
    return [
       charts.Series<CultivationDataSeries, DateTime>(
        domainFn: (CultivationDataSeries d, _) => d.timestamp,
        measureFn: (CultivationDataSeries d, _) => d.tones,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        id: 'Cultivations',
        data: categorize(trends))
      ..setAttribute(charts.rendererIdKey, 'customArea'),
    ];
  }

  createChartWidget() {
    var chart =  charts.TimeSeriesChart(getSeries(data),
      animate: true,
      customSeriesRenderers: [
         charts.LineRendererConfig(
          // ID used to link series to this renderer.
          customRendererId: 'customArea',
          includeArea: true,
          stacked: true),
    ]);

    return Padding(
      padding:  EdgeInsets.all(32.0),
      child:  SizedBox(
        height: 200.0,
        child: chart,
      ),
    );
  }

   @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          createChartWidget(),
          Text('Daily Trends')
      ]));
  }
}

// construct daily trends from time series
class DailyTrendsState extends
  AbstractTSChartState<DailyTrendsWidget> {

  DailyTrendsState(
    List<CultivationDataSeries> data): super(data, "Daily Trends");

  @override
  categorize(List<CultivationDataSeries> data) {
    return data;
  }
}

// construct weekly trends from timeseries (throughout the year)
class WeeklyTrendsState extends
  AbstractTSChartState<WeeklyTrendsWidget> {

  WeeklyTrendsState(List<CultivationDataSeries> data): super(data = data, "Weekly Trends");

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

}

// monthly trends state
class MonthlyTrendsState extends
  AbstractTSChartState<MonthlyTrendsWidget> {

  MonthlyTrendsState(List<CultivationDataSeries> data): super(data, "Monthly Trends");

  @override
  categorize(List<CultivationDataSeries> data) {
    // aggregate data by months for the year
    List<CultivationDataSeries> acc = List.generate(12, (int index) {
      print(index);
      return CultivationDataSeries(
        DateTime(2018, DateTime.january + index, 1), 0);
    });

    // iterate data and accumulate by similar month
    data.forEach((point) =>
      acc[point.timestamp.month - 1] + point.tones);

    return acc;
  }

}

class AnualTrendsState extends
  AbstractTSChartState<AnualTrendsWidget> {

  AnualTrendsState(List<CultivationDataSeries> data): super(data, "Anual Trends");

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
}
