#!/usr/bin/python
# Time and Date Utilities (dklrt).
# (c) David Keegan 2011-08-06.
import sys, re
from time import *
import datetime
import Misc

ModuleName = __name__
ReDateSep = '[-/]'
ReDate = '\d{4}%s\d{1,2}%s\d{1,2}' % (ReDateSep, ReDateSep)
RePeriod = '(\d+)([ymwdh])'

DateFormat = '%Y-%m-%d'

ReDateTimeSep = "[-/: ]";
DateTimeFormat = '%Y%m%d%H%M%S'

SecPerHour = 60
SecPerDay = 24 * SecPerHour * SecPerHour

def _Throw(Msg): Misc.Throw(Msg, ModuleName)

def DateTimeParse(DateTimeStr):
   """Converts a date(/time) string to seconds since the epoch.
      Assumes zeroes for missing time components.
   """
   Dts = re.sub(ReDateTimeSep, '', DateTimeStr);
   if len(Dts) < 8:
      _Throw('Bad Date/Time string: "%s"!' % DateTimeStr)
   while len(Dts) < 14: Dts = Dts + "0";
   return mktime(strptime(Dts, DateTimeFormat))

def DateToText(Seconds):
   # Round seconds to integer first as we're truncating the time
   # component.
   return strftime(DateFormat, localtime(round(Seconds)))

def DateToday():
   return DateTimeParse(DateToText(time()))

def DateAddPeriod(Seconds, Periodstr):
   """Adds the period to the Seconds (a date)."""
   Match = re.match(RePeriod, Periodstr)
   if not Match: _Throw("Bad Period String: %s!" % Periodstr)
   Count = int(Match.group(1))
   Unit = Match.group(2)

   Rv = Seconds
   if Unit == 'y': Rv = DateAddYears(Rv, Count)
   elif Unit== 'm': Rv = DateAddMonths(Rv, Count)
   elif Unit == 'w': Rv = Rv + (Count * SecPerDay * 7)
   elif Unit == 'd': Rv = Rv + (Count * SecPerDay)
   elif Unit == 'h': Rv = Rv + (Count * SecPerHour)
   else: _Throw('Bad Period Unit: "%s"!' % Unit)
   return Rv

def DateAddYears(Seconds, Count):
   """Shifts Seconds (a date) forward by Count years.
      If Seconds is Feb 29, shifts to Feb 28, even if shifing to a
      leap year.
   """
   if not isinstance(Count, (int, long)):
      _Throw("Count argument not an int!")

   dtd = datetime.date.fromtimestamp(Seconds)
   if not Count == 0:
      if (dtd.month == 2) and (dtd.day == 29):
         dtd = dtd.replace(day=28)
      dtd = dtd.replace(year=(dtd.year + Count))
   return mktime(dtd.timetuple())

def DateAddMonths(Seconds, Count):
   """Shifts Seconds (a date) forward by Count months.
      If the day is >= 29, shifts to 28.
   """
   if not isinstance(Count, (int, long)):
      _Throw("Count argument not an int!")

   dtd = datetime.date.fromtimestamp(Seconds)
   if not Count == 0:
      if dtd.day >= 29: dtd = dtd.replace(day=28)
      Month = (dtd.month + Count) - 1
      Years = Month / 12
      dtd = dtd.replace(year=(dtd.year + Years))
      Month = (Month % 12) + 1
      dtd = dtd.replace(month=Month)
   return mktime(dtd.timetuple())
