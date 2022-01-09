"""parser module
Load and write the configuration data from config file
-*- coding: utf-8 -*-
Copyright (c) 2021 `Gwenael Marchetti--waternaux
All Rights Reserved
Released under the MIT license
"""

from yaml import load, dump

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper


# region get data from yaml or cli args

def get_data_config(name):
    """
    Get configuration data from given args if used, else from .yaml file
    """
    data = get_data()
    try:
        value = data["db"][name]
        return value
    except:
        pass

    try:
        value = data[name]
        return value
    except:
        pass


def get_data():
    """
    Load data from config file
    :return: all the data
    """
    stream = open("config.yaml", "r")
    infos = load(stream, Loader=Loader)
    return infos

# endregion

