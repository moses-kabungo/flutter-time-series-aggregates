import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_101/models/cultivation-data-entry.dart';
import 'package:flutter_101/util/Fixtures.dart';
import 'package:flutter_101/util/cultivation-dataset-utils.dart';

void main() => runApp(AppHomePage());

class AppHomePage extends StatelessWidget {
  AppHomePage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.amber[700],
            accentColor: Colors.lightGreenAccent[200]),
        home: StatisticsWidget());
  }
}

class StatisticsWidget extends StatefulWidget {
  final String title;

  StatisticsWidget({Key key, this.title}) : super(key: key);

  @override
  _InternalState createState() => _InternalState();
}

class _InternalState extends State<StatisticsWidget> {
  /* todo: use appropiate lifecycle method to fetch data from
    an external source*/
  _InternalState() : this._data = Fixtures.data;

  // library private data
  final List<CultivationDataEntry> _data;

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
          body: TabBarView(children: [
            DailyTrendsWidget(_data),
            WeeklyTrendsWidget(_data),
            MonthlyTrendsWidget(_data),
            AnualTrendsWidget(_data)
          ]),
        ));
  }
}

// widget to display daily trends
class DailyTrendsWidget extends StatefulWidget {
  final List<CultivationDataEntry> data;

  DailyTrendsWidget(this.data);

  @override
  DailyTrendsState createState() => DailyTrendsState(this.data);
}

class WeeklyTrendsWidget extends StatefulWidget {
  final List<CultivationDataEntry> data;

  WeeklyTrendsWidget(this.data);

  @override
  WeeklyTrendsState createState() => WeeklyTrendsState(this.data);
}

class MonthlyTrendsWidget extends StatefulWidget {
  final List<CultivationDataEntry> trends;

  MonthlyTrendsWidget(this.trends);

  @override
  MonthlyTrendsState createState() => MonthlyTrendsState(trends);
}

class AnualTrendsWidget extends StatefulWidget {
  final List<CultivationDataEntry> trends;

  AnualTrendsWidget(this.trends);

  @override
  AnualTrendsState createState() => AnualTrendsState(trends);
}

abstract class AbstractTSChartState<T extends StatefulWidget> extends State<T> {
  final List<CultivationDataEntry> data;
  final String caption;

  AbstractTSChartState(this.data, this.caption);

  aggregate(List<CultivationDataEntry> data);

  getSeries(List<CultivationDataEntry> trends) {
    return [
      charts.Series<CultivationDataEntry, DateTime>(
          domainFn: (CultivationDataEntry d, _) => d.timestamp,
          measureFn: (CultivationDataEntry d, _) => d.tones,
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
          id: 'Cultivations',
          data: aggregate(trends))
        ..setAttribute(charts.rendererIdKey, 'customArea'),
    ];
  }

  createChartWidget() {
    var chart = charts.TimeSeriesChart(getSeries(data),
        animate: true,
        customSeriesRenderers: [
          charts.LineRendererConfig(
              // ID used to link series to this renderer.
              customRendererId: 'customArea',
              includeArea: true,
              stacked: true),
        ]);

    return Padding(
      padding: EdgeInsets.all(32.0),
      child: SizedBox(
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
            children: <Widget>[createChartWidget(), Text('Daily Trends')]));
  }
}

// construct daily trends from time series
class DailyTrendsState extends AbstractTSChartState<DailyTrendsWidget> {
  DailyTrendsState(List<CultivationDataEntry> data)
      : super(data, "Daily Trends");

  @override
  aggregate(List<CultivationDataEntry> data) {
    return data;
  }
}

// construct weekly trends from timeseries (throughout the year)
class WeeklyTrendsState extends AbstractTSChartState<WeeklyTrendsWidget> {
  WeeklyTrendsState(List<CultivationDataEntry> data)
      : super(data = data, "Weekly Trends");

  @override
  aggregate(List<CultivationDataEntry> data) {
    // generate dates starting from the first date of the year
    var firstThursday = DateTime.utc(2018, DateTime.january, 1);

    if (firstThursday.weekday != DateTime.thursday) {
      firstThursday = DateTime.utc(
          2018, DateTime.january, 1 + ((4 - firstThursday.weekday) + 7) % 7);
    }

    getWeekNumberForDate(DateTime date) {
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
      var x = targetThursday.millisecondsSinceEpoch -
          firstThursday.millisecondsSinceEpoch;
      return x.ceil() ~/ 604800000;
    }

    List<CultivationDataEntry> acc = List.generate(52, (int index) {
      return CultivationDataEntry.onDateOf(
          firstThursday.add(Duration(days: index * 7)))
        ..tones = 0;
    });

    data.forEach((CultivationDataEntry el) {
      // retrieve corresponding week item
      int index = getWeekNumberForDate(el.timestamp);
      if (index > 51) {
        return;
      }
      acc[index] += el.tones;
    });

    // aggregate data into weeks
    // print(getWeekNumberForDate(acc.last.timestamp));

    return acc;
  }
}

// monthly trends state
class MonthlyTrendsState extends AbstractTSChartState<MonthlyTrendsWidget> {
  MonthlyTrendsState(List<CultivationDataEntry> data)
      : super(data, "Monthly Trends");

  @override
  aggregate(List<CultivationDataEntry> data) {
    // aggregate data by months for the year
    List<CultivationDataEntry> acc = List.generate(12, (int index) {
      return CultivationDataEntry.onDateOf(
          DateTime(2018, DateTime.january + index, 1))
        ..tones = 0;
    });

    // iterate data and accumulate by similar month
    data.forEach((point) => acc[point.timestamp.month - 1] + point.tones);

    return acc;
  }
}

class AnualTrendsState extends AbstractTSChartState<AnualTrendsWidget> {
  AnualTrendsState(List<CultivationDataEntry> data)
      : super(data, "Anual Trends");

  @override
  aggregate(List<CultivationDataEntry> data) {
    // find the minimum year in the dataset
    CultivationDatasetUtils.sortByDateAsc(data);

    var yearOne = data.first.timestamp.year;
    var finalYear = data.last.timestamp.year;

    // aggregate for the same year
    List<CultivationDataEntry> acc =
        List.generate(finalYear - yearOne + 1, (int index) {
      return CultivationDataEntry.onDateOf(
          DateTime.utc(yearOne + index, DateTime.january, 1))
        ..tones = 0;
    });

    // aggregate data by years
    data.forEach((e) {
      int index = acc.map(
        (entry) => entry.timestamp.year).toList().indexOf(e.timestamp.year);

      // perform commulative summation
      acc[index] += e.tones;
    });

    return acc;
  }
}
