#!/usr/bin/python
# Miscellaneous Utilities (dklrt).
# (c) David Keegan 2011-06-28.

from __future__ import print_function
import sys

def Out(*Args):
   print(*Args, file=sys.stdout)
   return

def Err(*Args):
   print(*Args, file=sys.stderr)
   return

def Nm(Context):
   if Context is None: return '?'
   else: return Context.__class__.__name__

def Lnm(Context):
   if Context is None: return '?'
   else: return Context.__class__.__module__ + '.' + Nm(Context)

def Pf(Context):
   return Lnm(Context) + ">>>"

def Repr(Text, Context=None):
   return Lnm(Context) + '(' + Text + ')'

def Log(Message, Context=None):
   print(Pf(Context) + Message)

def Throw(Message, Context=None):
   Em = Pf(Context) + Message
   Log(Em)
   raise Exception(Em)

def Denone(Text):
   if Text is None: return '<None>'
   else: return Text
