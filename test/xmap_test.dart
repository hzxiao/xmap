import 'package:test/test.dart';

import 'package:xmap/xmap.dart';

void main() {
  test('test getInt', () {
    var x = XMap();
    x['int'] = 1;
    x['str'] = '2';
    x['double'] = 2.2;
    x['map'] = {"int": 1};
    expect(1, x.getInt('int'));
    expect(2, x.getInt('str'));
    expect(2, x.getInt('double'));
    expect(null, x.getInt('null'));
    expect(0, x.getInt('default', defaultValue: 0));
    expect(1, x.getInt('map.int'));
    expect(2, x.getInt('int.2', defaultValue: 2));
    expect(null, x.getInt(null));
  });
  test('test getDouble', () {
    var x = XMap.from({
      'double': 1.2,
      'int': 1,
      'str': '2.3',
      'map': {
        'double': 1.2,
        'int': 1,
        'str': '2.3',
      },
      'list': [1, 2, 3]
    });
    expect(1.2, x.getDouble('double'));
    expect(1, x.getDouble('int'));
    expect(2.3, x.getDouble('str', defaultValue: 0));
    expect(1, x.getDouble('map.int'));
    expect(1.2, x.getDouble('map.double'));
    expect(2.3, x.getDouble('map.str', defaultValue: 0));
    expect(2.3, x.getDouble('str', defaultValue: 0));
    expect(2, x.getDouble('list.1', defaultValue: 0));
    expect(0, x.getDouble('other', defaultValue: 0));
  });
  test('test getBool', () {});
  test('test getString', () {});
  test('test getMap', () {
    var x = XMap.from({
      'map': {
        'int': 1,
        'map': {'str': 'foo'}
      },
      'list': [
        {"int": 1}
      ],
      'xmap': XMap.from({"int": 1})
    });
    expect({'str': 'foo'}, x.getMap('map.map'));
    expect({'str': 'foo'}, x.getXMap('map')?.getMap('map'));
    expect({'int': 1}, x.getMap('list.0'));
    expect({'int': 1}, x.getMap('xmap'));
    expect(null, x.getMap('null'));
  });
  test('test getXMap', () {
    var x = XMap.from({
      'map': {
        'int': 1,
        'map': {'str': 'foo'}
      },
      'list': [
        {"int": 1}
      ],
      'xmap': XMap.from({"int": 1})
    });
    expect({'str': 'foo'}, x.getXMap('map.map').toMap());
    expect({'str': 'foo'}, x.getXMap('map')?.getXMap('map')?.toMap());
    expect({'int': 1}, x.getXMap('list.0').toMap());
    expect({'int': 1}, x.getXMap('xmap').toMap());
    expect(null, x.getXMap('null'));
  });

  test('test getList', () {
    var x = XMap.from({
      'list_int': [1, 2, 3],
      'list_double': [1.1, 2.2, 3.3],
      'list_bool': [true, false],
      'list_String': ['foo', 'bar'],
      'list_XMap': [
        XMap.from({'int': 1}),
        XMap.from({'foo': 'bar'})
      ]
    });
    expect([1, 2, 3], x.getList<int>('list_int'));
    expect([1.1, 2.2, 3.3], x.getList<double>('list_double'));
    expect([true, false], x.getList<bool>('list_bool'));
    expect(['foo', 'bar'], x.getList<String>('list_String'));
    expect({'int': 1}, x.getList<XMap>('list_XMap')[0].toMap());
    expect({'foo': 'bar'}, x.getList<XMap>('list_XMap')[1].toMap());
  });
}
