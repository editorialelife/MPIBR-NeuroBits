classdef (Sealed) LSMSpecs < handle
  %LSMSpecs List of LSM fields
  % OO version of LSM_H.m file created by Peter Li (available on the Matlab
  % file exchange: http://www.mathworks.com/matlabcentral/fileexchange/8412-lsm-file-toolbox)
  % The class is basically a connection of constant properties, which
  % represents the metadata fields found in LSM files
  
  properties
    LSMINF;
    SCANINFO_HEXTAGMAP;
    SAMPLINGMODE_MAP;
  end
  
  %we want the behaviour to be static, so the class behaves like a
  %singleton
  methods (Access = private)
    function obj = LSMSpecs
      [obj.LSMINF, obj.SCANINFO_HEXTAGMAP, obj.SAMPLINGMODE_MAP] = obj.populateMaps();
    end
  end
   
  methods (Static)
    function singleObj = getInstance
      persistent localObj
      if isempty(localObj) || ~isvalid(localObj)
        localObj = LSMSpecs;
      end
      singleObj = localObj;
    end
 
    function [lsminf, scan, samp] = populateMaps()
      lsminf = cell(67,1);
      lsminf{1}  = {'unknown1'                 8,  'uchar'    };
      lsminf{2}  = {'DIMENSIONS'               3,  'uint32'   };
      lsminf{3}  = {'NUMBER_OF_CHANNELS'       1,  'uint32'   };
      lsminf{4}  = {'TIMESTACKSIZE'            1,  'uint32'   };
      lsminf{5}  = {'datatype1'                1,  'uint32'   };
      lsminf{6}  = {'unknown2'                 8,  'uchar'    };
      lsminf{7}  = {'VOXELSIZES'               3,  'float64'  };
      lsminf{8}  = {'unknown3'                 24, 'uchar'    };
      lsminf{9}  = {'SCANTYPE'                 1,  'uint16'   };
      lsminf{10} = {'SPECTRALSCAN'             1,  'uint16'   };
      lsminf{11} = {'datatype'                 1,  'uint32'   };
      lsminf{12} = {'unknown4'                 1,  'uint32'   };
      lsminf{13} = {'OFFSET_INPUTLUT'          1,  'uint32'   };
      lsminf{14} = {'OFFSET_OUTPUTLUT'         1,  'uint32'   };
      lsminf{15} = {'OFFSET_CHANNELSCOLORS'    1,  'uint32'   };
      lsminf{16} = {'unknown5'                 8,  'uchar'    };
      lsminf{17} = {'OFFSET_CHANNELDATATYPES'  1,  'uint32'   };
      lsminf{18} = {'OFFSET_SCANINFO'          1,  'uint32'   };
      lsminf{19} = {'unknown6'                 1,  'uint32'   };
      lsminf{20} = {'OFFSET_TIMESTAMPS'        1,  'uint32'   };
      lsminf{21} = {'unknown7'                 68, 'uchar'    };
      lsminf{22} = {'OFFSET_CHANNELWAVELENGTH' 1,  'uint32'   };
      lsminf{23} = {'MagicNumber'              1,  'uint32'   };
      lsminf{24} = {'StructureSize'            1,  'uint32'   };
      lsminf{25} = {'DimensionX'               1,  'uint32'   };
      lsminf{26} = {'DimensionY'               1,  'uint32'   };
      lsminf{27} = {'DimensionZ'               1,  'uint32'   };
      lsminf{28} = {'DimensionChannels'        1,  'uint32'   };
      lsminf{29} = {'DimensionTime'            1,  'uint32'   };
      lsminf{30} = {'IntensityDataType'        1,  'uint32'   };
      lsminf{31} = {'ThumbnailX'               1,  'uint32'   };
      lsminf{32} = {'ThumbnailY'               1,  'uint32'   };
      lsminf{33} = {'VoxelSizeX'               1,  'float64'  };
      lsminf{34} = {'VoxelSizeY'               1,  'float64'  };
      lsminf{35} = {'VoxelSizeZ'               1,  'float64'  };
      lsminf{36} = {'OriginX'                  1,  'float64'  };
      lsminf{37} = {'OriginY'                  1,  'float64'  };
      lsminf{38} = {'OriginZ'                  1,  'float64'  };
      lsminf{39} = {'ScanType'                 1,  'uint16'   };
      lsminf{40} = {'SpectralScan'             1,  'uint16'   };
      lsminf{41} = {'DataType'                 1,  'uint32'   };
      lsminf{42} = {'OffsetVectorOverlay',     1,  'uint32'   };
      lsminf{43} = {'OffsetInputLut'           1,  'uint32'   };
      lsminf{44} = {'OffsetOutputLut'          1,  'uint32'   };
      lsminf{45} = {'OffsetChannelColors',     1,  'uint32'   };
      lsminf{46} = {'TimeInterval'             1,  'float64'  };
      lsminf{47} = {'OffsetChannelDataTypes',  1,  'uint32'   };
      lsminf{48} = {'OffsetScanInformation',   1,  'uint32'   };
      lsminf{49} = {'OffsetKsData'             1,  'uint32'   };
      lsminf{50} = {'OffsetTimeStamps'         1,  'uint32'   };
      lsminf{51} = {'OffsetEventList'          1,  'uint32'   };
      lsminf{52} = {'OffsetRoi'                1,  'uint32'   };
      lsminf{53} = {'OffsetBleachRoi'          1,  'uint32'   };
      lsminf{54} = {'OffsetNextRecording',     1,  'uint32'   };
      lsminf{55} = {'DisplayAspectX'           1,  'float64'  };
      lsminf{56} = {'DisplayAspectY'           1,  'float64'  };
      lsminf{57} = {'DisplayAspectZ'           1,  'float64'  };
      lsminf{58} = {'DisplayAspectTime'        1,  'float64'  };
      lsminf{59} = {'OffsetMeanOfRoisOverlay', 1,  'uint32'   };
      lsminf{60} = {'OffsetTopoIsolineOverlay' 1,  'uint32'   };
      lsminf{61} = {'OffsetTopoProfileOverlay' 1,  'uint32'   };
      lsminf{62} = {'OffsetLinescanOverlay',   1,  'uint32'   };
      lsminf{63} = {'ToolbarFlags'             1,  'uint32'   };
      lsminf{64} = {'OffsetChannelWavelenth',  1,  'uint32'   };
      lsminf{65} = {'OffsetChannelFactors',    1,  'uint32'   };
      lsminf{66} = {'ObjectiveSphereCorrection' 1,  'float64'  };
      lsminf{67} = {'OffsetUnmixParameters',   1,  'uint32'   };

      scan = cell(185,1);
      scan{1}   = {'h10000000',    'RECORDINGS'                      };
      scan{2}   = {'h10000001',    'ENTRY_NAME'                      };
      scan{3}   = {'h10000002',    'ENTRY_DESCRIPTION'               };
      scan{4}   = {'h10000003',    'ENTRY_NOTES'                   	 };
      scan{5}   = {'h10000004',    'ENTRY_OBJECTIVE'                 };
      scan{6}   = {'h10000005',    'PROCESSING_SUMMARY'              };
      scan{7}   = {'h10000006',    'SPECIAL_SCAN'                    };
      scan{8}   = {'h10000007',    'SCAN_TYPE'                       };
      scan{9}   = {'h10000008',    'SCAN_MODE'                       };
      scan{10}  = {'h10000009',    'STACKS_COUNT'                    };
      scan{11}  = {'h1000000A',    'LINES_PER_PLANE'                 };
      scan{12}  = {'h1000000B',    'SAMPLES_PER_LINE'                };
      scan{13}  = {'h1000000C',    'PLANES_PER_VOLUME'               };
      scan{14}  = {'h1000000D',    'IMAGES_WIDTH'                    };
      scan{15}  = {'h1000000E',    'IMAGES_HEIGHT'                   };
      scan{16}  = {'h1000000F',    'NUMBER_OF_PLANES'                };
      scan{17}  = {'h10000010',    'IMAGES_NUMBER_STACKS'            };
      scan{18}  = {'h10000011',    'IMAGES_NUMBER_CHANNELS'          };
      scan{19}  = {'h10000012',    'LINESCAN_X_Y'                     };
      scan{20}  = {'h10000013',    'SCAN_DIRECTION'                  };
      scan{21}  = {'h10000014',    'TIME_SERIES'                   	 };
      scan{22}  = {'h10000015',    'ORIGNAL_SCAN_DATA'             	 };
      scan{23}  = {'h10000016',    'ZOOM_X'                          };
      scan{24}  = {'h10000017',    'ZOOM_Y'                          };
      scan{25}  = {'h10000018',    'ZOOM_Z'                          };
      scan{26}  = {'h10000019',    'SAMPLE_0_X'                       };
      scan{27}  = {'h1000001A',    'SAMPLE_0_Y'                       };
      scan{28}  = {'h1000001B',    'SAMPLE_0_Z'                       };
      scan{29}  = {'h1000001C',    'SAMPLE_SPACING'                  };
      scan{30}  = {'h1000001D',    'LINE_SPACING'                    };
      scan{31}  = {'h1000001E',    'PLANE_SPACING'                   };
      scan{32}  = {'h1000001F',    'PLANE_WIDTH'                     };
      scan{33}  = {'h10000020',    'PLANE_HEIGHT'                    };
      scan{34}  = {'h10000021',    'VOLUME_DEPTH'                  	 };
      scan{35}  = {'h10000034',    'ROTATION'                      	 };
      scan{36}  = {'h10000035',    'PRECESSION'                    	 };
      scan{37}  = {'h10000036',    'SAMPLE_0_TIME'                  	 };
      scan{38}  = {'h10000037',    'START_SCAN_TRIGGER_IN'         	 };
      scan{39}  = {'h10000038',    'START_SCAN_TRIGGER_OUT'          };
      scan{40}  = {'h10000039',    'START_SCAN_EVENT'                };
      scan{41}  = {'h10000040',    'START_SCAN_TIME'                 };
      scan{42}  = {'h10000041',    'STOP_SCAN_TRIGGER_IN'            };
      scan{43}  = {'h10000042',    'STOP_SCAN_TRIGGER_OUT'           };
      scan{44}  = {'h10000043',    'STOP_SCAN_EVENT'                 };
      scan{45}  = {'h10000044',    'START_SCAN_TIME2'                };
      scan{46}  = {'h10000045',    'USE_ROIS'                        };
      scan{47}  = {'h10000046',    'USE_REDUCED_MEMORY_ROIS'         };
      scan{48}  = {'h10000047',    'USER'                            };
      scan{49}  = {'h10000048',    'USE_BCCORECCTION'                };
      scan{50}  = {'h10000049',    'POSITION_BCCORRECTION1'        	 };
      scan{51}  = {'h10000050',    'POSITION_BCCORRECTION2'        	 };
      scan{52}  = {'h10000051',    'INTERPOLATIONY'                  };
      scan{53}  = {'h10000052',    'CAMERA_BINNING'                  };
      scan{54}  = {'h10000053',    'CAMERA_SUPERSAMPLING'            };
      scan{55}  = {'h10000054',    'CAMERA_FRAME_WIDTH'              };
      scan{56}  = {'h10000055',    'CAMERA_FRAME_HEIGHT'             };
      scan{57}  = {'h10000056',    'CAMERA_OFFSETX'                  };
      scan{58}  = {'h10000057',    'CAMERA_OFFSETY'                  };
      scan{59}  = {'h11000000',    'TIMERS'                          };
      scan{60}  = {'h12000000',    'TIMER'                           };
      scan{61}  = {'h12000001',    'TIMER_NAME'                      };
      scan{62}  = {'h12000003',    'INTERVAL'                        };
      scan{63}  = {'h12000004',    'TRIGGER_IN'                      };
      scan{64}  = {'h12000005',    'TRIGGER_OUT'                     };
      scan{65}  = {'h13000000',    'MARKERS'                         };
      scan{66}  = {'h14000000',    'MARKER'                          };
      scan{67}  = {'h14000001',    'MARKER_NAME'                     };
      scan{68}  = {'h14000002',    'DESCRIPTION'                     };
      scan{69}  = {'h14000003',    'TRIGGER_IN'                      };
      scan{70}  = {'h14000004',    'TRIGGER_OUT'                   	 };
      scan{71}  = {'h20000000',    'TRACKS'                          };
      scan{72}  = {'h30000000',    'LASERS'                          };
      scan{73}  = {'h40000000',    'TRACK'                           };
      scan{74}  = {'h40000001',    'MULTIPLEX_TYPE'                  };
      scan{75}  = {'h40000002',    'MULTIPLEX_ORDER'	               };
      scan{76}  = {'h40000003',    'SAMPLING_MODE'                   };
      scan{77}  = {'h40000004',    'SAMPLING_METHOD'	               };
      scan{78}  = {'h40000005',    'SAMPLING_NUMBER'	               };
      scan{79}  = {'h40000006',    'ENTRY_ACQUIRE'                   };
      scan{80}  = {'h40000007',    'OBSERVATION_TIME'	               };
      scan{81}  = {'h4000000B',    'TIME_BETWEEN_STACKS'	           };
      scan{82}  = {'h4000000C',    'TRACK_NAME'                      };
      scan{83}  = {'h4000000D',    'COLLIMATOR1_NAME'	               };
      scan{84}  = {'h4000000E',    'COLLIMATOR1_POSITION'            };
      scan{85}  = {'h4000000F',    'COLLIMATOR2_NAME'                };
      scan{86}  = {'h40000010',    'COLLIMATOR2_POSITION'            };
      scan{87}  = {'h40000011',    'BLEACH_TRACK'                    };
      scan{88}  = {'h40000012',    'BLEACH_AFTER_SCAN_NUMBER'        };
      scan{89}  = {'h40000013',    'BLEACH_SCAN_NUMBER'              };
      scan{90}  = {'h40000014',    'TRIGGER_IN'                      };
      scan{91}  = {'h40000015',    'TRIGGER_OUT'                     };
      scan{92}  = {'h40000016',    'IS_RATIO_TRACK'                  };
      scan{93}  = {'h40000017',    'BLEACH_COUNT'                    };
      scan{94}  = {'h40000018',    'SPI_CENTER_WAVELENGTH'           };
      scan{95}  = {'h40000019',    'PIXEL_TIME'                      };
      scan{96}  = {'h40000020',    'ID_CONDENSOR_FRONTLENS'          };
      scan{97}  = {'h40000021',    'CONDENSOR_FRONTLENS'             };
      scan{98}  = {'h40000022',    'ID_FIELD_STOP'                   };
      scan{99}  = {'h40000023',    'FIELD_STOP_VALUE'                };
      scan{100} = {'h40000024',    'ID_CONDENSOR_APERTURE'           };
      %got lazy
      cnt = 101;
      scan{cnt} = {'h40000025',    'CONDENSOR_APERTURE'              }; cnt = cnt+1;
      scan{cnt} = {'h40000026',    'ID_CONDENSOR_REVOLVER'           }; cnt = cnt+1;
      scan{cnt} = {'h40000027',    'CONDENSOR_FILTER'                }; cnt = cnt+1;
      scan{cnt} = {'h40000028',    'ID_TRANSMISSION_FILTER1'         }; cnt = cnt+1;
      scan{cnt} = {'h40000029',    'ID_TRANSMISSION1'                }; cnt = cnt+1;
      scan{cnt} = {'h40000030',    'ID_TRANSMISSION_FILTER2'         }; cnt = cnt+1;
      scan{cnt} = {'h40000031',    'ID_TRANSMISSION2'                }; cnt = cnt+1;
      scan{cnt} = {'h40000032',    'REPEAT_BLEACH'                   }; cnt = cnt+1;
      scan{cnt} = {'h40000033',    'ENABLE_SPOT_BLEACH_POS'          }; cnt = cnt+1;
      scan{cnt} = {'h40000034',    'SPOT_BLEACH_POSX'	               }; cnt = cnt+1;
      scan{cnt} = {'h40000035',    'SPOT_BLEACH_POSY'	               }; cnt = cnt+1;
      scan{cnt} = {'h40000036',    'BLEACH_POSITION_Z'	             }; cnt = cnt+1;
      scan{cnt} = {'h40000037',    'ID_TUBELENS'                     }; cnt = cnt+1;
      scan{cnt} = {'h40000038',    'ID_TUBELENS_POSITION'          	 }; cnt = cnt+1;
      scan{cnt} = {'h40000039',    'TRANSMITTED_LIGHT'             	 }; cnt = cnt+1;
      scan{cnt} = {'h4000003a',    'REFLECTED_LIGHT'	               }; cnt = cnt+1;
      scan{cnt} = {'h4000003b',    'TRACK_SIMULTAN_GRAB_AND_BLEACH'  }; cnt = cnt+1;
      scan{cnt} = {'h4000003c',    'BLEACH_PIXEL_TIME'	             }; cnt = cnt+1;
      scan{cnt} = {'h50000000',    'LASER'	                         }; cnt = cnt+1;
      scan{cnt} = {'h50000001',    'LASER_NAME'                      }; cnt = cnt+1;
      scan{cnt} = {'h50000002',    'LASER_ACQUIRE'                   }; cnt = cnt+1;
      scan{cnt} = {'h50000003',    'LASER_POWER'                     }; cnt = cnt+1;
      scan{cnt} = {'h60000000',    'DETECTION_CHANNELS'              }; cnt = cnt+1;
      scan{cnt} = {'h70000000',    'DETECTION_CHANNEL'	             }; cnt = cnt+1;
      scan{cnt} = {'h70000003',    'DETECTOR_GAIN'                   }; cnt = cnt+1;
      scan{cnt} = {'h70000005',    'AMPLIFIER_GAIN'                  }; cnt = cnt+1;
      scan{cnt} = {'h70000007',    'AMPLIFIER_OFFSET'                }; cnt = cnt+1;
      scan{cnt} = {'h70000009',    'PINHOLE_DIAMETER'                }; cnt = cnt+1;
      scan{cnt} = {'h7000000B',    'ENTRY_ACQUIRE'                   }; cnt = cnt+1;
      scan{cnt} = {'h7000000C',    'DETECTOR_NAME'                   }; cnt = cnt+1;
      scan{cnt} = {'h7000000D',    'AMPLIFIER_NAME'                  }; cnt = cnt+1;
      scan{cnt} = {'h7000000E',    'PINHOLE_NAME'                    }; cnt = cnt+1;
      scan{cnt} = {'h7000000F',    'FILTER_SET_NAME'                 }; cnt = cnt+1;
      scan{cnt} = {'h70000010',    'FILTER_NAME'                   	 }; cnt = cnt+1;
      scan{cnt} = {'h70000013',    'INTEGRATOR_NAME'                 }; cnt = cnt+1;
      scan{cnt} = {'h70000014',    'DETECTION_CHANNEL_NAME'          }; cnt = cnt+1;
      scan{cnt} = {'h70000015',    'DETECTOR_GAIN_BC1'               }; cnt = cnt+1;
      scan{cnt} = {'h70000016',    'DETECTOR_GAIN_BC2'               }; cnt = cnt+1;
      scan{cnt} = {'h70000017',    'AMPLIFIER_GAIN_BC1'              }; cnt = cnt+1;
      scan{cnt} = {'h70000018',    'AMPLIFIER_GAIN_BC2'              }; cnt = cnt+1;
      scan{cnt} = {'h70000019',    'AMPLIFIER_OFFSET_BC1'            }; cnt = cnt+1;
      scan{cnt} = {'h70000020',    'AMPLIFIER_OFFSET_BC2'            }; cnt = cnt+1;
      scan{cnt} = {'h70000021',    'SPECTRAL_SCAN_CHANNELS'          }; cnt = cnt+1;
      scan{cnt} = {'h70000022',    'SPI_WAVE_LENGTH_START'         	 }; cnt = cnt+1;
      scan{cnt} = {'h70000023',    'SPI_WAVELENGTH_END'              }; cnt = cnt+1;
      scan{cnt} = {'h70000026',    'DYE_NAME'                        }; cnt = cnt+1;
      scan{cnt} = {'h70000027',    'DYE_FOLDER'                      }; cnt = cnt+1;
      scan{cnt} = {'h80000000',    'ILLUMINATION_CHANNELS'           }; cnt = cnt+1;
      scan{cnt} = {'h90000000',    'ILLUMINATION_CHANNEL'            }; cnt = cnt+1;
      scan{cnt} = {'h90000001',    'ILL_NAME'                        }; cnt = cnt+1;
      scan{cnt} = {'h90000002',    'POWER'                           }; cnt = cnt+1;
      scan{cnt} = {'h90000003',    'WAVELENGTH'                      }; cnt = cnt+1;
      scan{cnt} = {'h90000004',    'ACQUIRE'                         }; cnt = cnt+1;
      scan{cnt} = {'h90000005',    'DETCHANNEL_NAME'                 }; cnt = cnt+1;
      scan{cnt} = {'h90000006',    'POWER_BC1'                       }; cnt = cnt+1;
      scan{cnt} = {'h90000007',    'POWER_BC2'                       }; cnt = cnt+1;
      scan{cnt} = {'hA0000000',    'BEAM_SPLITTERS'                  }; cnt = cnt+1;
      scan{cnt} = {'hB0000000',    'BEAM_SPLITTER'                   }; cnt = cnt+1;
      scan{cnt} = {'hB0000001',    'FILTER_SET'                      }; cnt = cnt+1;
      scan{cnt} = {'hB0000002',    'FILTER'                          }; cnt = cnt+1;
      scan{cnt} = {'hB0000003',    'BS_NAME'                         }; cnt = cnt+1;
      scan{cnt} = {'hC0000000',    'DATA_CHANNELS'                   }; cnt = cnt+1;
      scan{cnt} = {'hD0000000',    'DATA_CHANNEL'                    }; cnt = cnt+1;
      scan{cnt} = {'hD0000001',    'DATA_NAME'                       }; cnt = cnt+1;
      scan{cnt} = {'hD0000004',    'COLOR'	                         }; cnt = cnt+1;
      scan{cnt} = {'hD0000005',    'SAMPLETYPE'	                     }; cnt = cnt+1;
      scan{cnt} = {'hD0000006',    'BITS_PER_SAMPLE'                 }; cnt = cnt+1;
      scan{cnt} = {'hD0000007',    'RATIO_TYPE'                      }; cnt = cnt+1;
      scan{cnt} = {'hD0000008',    'RATIO_TRACK1'                    }; cnt = cnt+1;
      scan{cnt} = {'hD0000009',    'RATIO_TRACK2'                    }; cnt = cnt+1;
      scan{cnt} = {'hD000000A',    'RATIO_CHANNEL1'                  }; cnt = cnt+1;
      scan{cnt} = {'hD000000B',    'RATIO_CHANNEL2'                  }; cnt = cnt+1;
      scan{cnt} = {'hD000000C',    'RATIO_CONST1'                    }; cnt = cnt+1;
      scan{cnt} = {'hD000000D',    'RATIO_CONST2'                    }; cnt = cnt+1;
      scan{cnt} = {'hD000000E',    'RATIO_CONST3'                    }; cnt = cnt+1;
      scan{cnt} = {'hD000000F',    'RATIO_CONST4'                    }; cnt = cnt+1;
      scan{cnt} = {'hD0000010',    'RATIO_CONST5'                    }; cnt = cnt+1;
      scan{cnt} = {'hD0000011',    'RATIO_CONST6'                    }; cnt = cnt+1;
      scan{cnt} = {'hD0000012',    'RATIO_FIRST_IMAGES1'	           }; cnt = cnt+1;
      scan{cnt} = {'hD0000013',    'RATIO_FIRST_IMAGES2'	           }; cnt = cnt+1;
      scan{cnt} = {'hD0000014',    'DYE_NAME'                        }; cnt = cnt+1;
      scan{cnt} = {'hD0000015',    'DYE_FOLDER'                      }; cnt = cnt+1;
      scan{cnt} = {'hD0000016',    'SPECTRUM'                        }; cnt = cnt+1;
      scan{cnt} = {'hD0000017',    'ACQUIRE'                         }; cnt = cnt+1;
      scan{cnt} = {'hFFFFFFFF',    'END_SUBBLOCK'                    };

      samp = containers.Map('KeyType', 'char', 'ValueType', 'char');
      samp('x0')   = 'Sample - No Average' ;
      samp('x1')   = 'Line Average'        ;
      samp('x2')   = 'Frame Average'       ;
      samp('x3')   = 'Integration Mode'    ;
    end
  end
end

