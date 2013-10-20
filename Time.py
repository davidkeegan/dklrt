#!/usr/bin/python
# Time and Date Utilities.
# (c) David Keegan 2011-08-06.
import sys, re
from time import *
import datetime
import Misc

ModuleName = __name__
ReDateSep = '[-/]'
ReDate = '\d{4}%s\d{1,2}%s\d{1,2}' % (ReDateSep, ReDateSep)
RePeriod = '(\d+)([ymwd])'

DateFormat = '%Y-%m-%d'

SecPerDay = 24 * 60 * 60

def _Throw(Msg): Misc.Throw(Msg, ModuleName)

def DateParse(Datestr):
   """Converts a date string to seconds since the epoch."""
   return mktime(strptime(Datestr, DateFormat))

def DateToText(Seconds):
   # Round seconds to integer first as we're truncating the time
   # component.
   return strftime(DateFormat, localtime(round(Seconds)))

def DateToday():
   return DateParse(DateToText(time()))

def DateAddPeriod(Seconds, Periodstr):
   """Adds the period to the Seconds (a date)."""

   Match = re.match(RePeriod, Periodstr)
   if not Match: _Throw("Bad Period String: %s!", Periodstr)
   Count = int(Match.group(1))
   Unit = Match.group(2)

   Rv = Seconds
   if Unit == 'y': Rv = DateAddYears(Rv, Count)
   elif Unit== 'm': Rv = DateAddMonths(Rv, Count)
   elif Unit == 'w': Rv = Rv + (Count * SecPerDay * 7)
   elif Unit == 'd': Rv = Rv + (Count * SecPerDay)
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
