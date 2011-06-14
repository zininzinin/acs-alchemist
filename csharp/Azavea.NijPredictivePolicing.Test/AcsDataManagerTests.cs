﻿using NUnit.Framework;
using log4net;
using System.IO;
using System.Collections.Generic;
using Azavea.NijPredictivePolicing.Test.Helpers;
using Azavea.NijPredictivePolicing.AcsImporterLibrary.Transfer;
using SharpMap.CoordinateSystems;
using GeoAPI.Geometries;
using Azavea.NijPredictivePolicing.AcsImporterLibrary;
using Azavea.NijPredictivePolicing.Common;
using Azavea.NijPredictivePolicing.Common.DB;
using System.Text;using System;using log4net.Core;
using System.Data;
using System.Data.Common;
namespace Azavea.NijPredictivePolicing.Test.AcsImporterLibrary
{
    [TestFixture]
    public class AcsDataManagerTests
    {
        private static ILog _log = null;
        public const string WorkingPath = @"C:\projects\Temple_Univ_NIJ_Predictive_Policing\csharp\Azavea.NijPredictivePolicing.Test";
        

        /// <summary>
        /// Place to dump files generated by tests
        /// </summary>
        protected const string OutputDir = @"output\";

        [TestFixtureSetUp]
        public void Init()
        {
            _log = LogHelpers.ResetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

            if (!Directory.Exists(OutputDir))
                Directory.CreateDirectory(OutputDir);
        }

        [Test]
        public void GetShapefileFeatures()
        {
            var features = new List<IGeometry>();
            var features2 = new List<IGeometry>();

            var man = GetManager();

            features = man.GetFilteringGeometries(GetShapePath(man, "DoesNotExist.shp"), 
                GeographicCoordinateSystem.WGS84);
            Assert.AreEqual(features, null);

            features = man.GetFilteringGeometries(GetShapePath(man, "bg42_d00.shp"), GeographicCoordinateSystem.WGS84);
            Assert.AreEqual(features, null);

            features = man.GetFilteringGeometries(GetShapePath(man, "bg42_d00_nosrid.shp"), 
                GeographicCoordinateSystem.WGS84);
            Assert.IsTrue(features.Count > 0);

            features = man.GetFilteringGeometries(GetShapePath(man, "bg42_d00_srid.shp"), 
                GeographicCoordinateSystem.WGS84);
            Assert.IsTrue(features.Count > 0);

            features2 = man.GetFilteringGeometries(GetShapePath(man, "bg42_d00_srid.shp"),
                GeographicCoordinateSystem.WGS84);
        }

        [Test]
        public void ImportVariablesFile()
        {
            var man = GetManager();
            man.WorkingPath = Path.Combine(man.WorkingPath, "ColumnFiles");
            man.CheckColumnMappingsFile();

            var invalidInputs = new string[] {
                "Invalid101Lines.txt",
                "InvalidAllDupes.txt",
                "InvalidEmpty.txt",
                "InvalidLotsOfDupes.txt",
                "InvalidMoECollisions.txt",
                "InvalidReservedCollisions.txt",
                "InvalidTruncCollisions.txt"
            };            

            for(int i = 0; i < invalidInputs.Length; i++)
            {
                invalidInputs[i] = Path.Combine(man.WorkingPath, invalidInputs[i]);
            }

            /************************************************************************************/

            string Valid100Lines = Path.Combine(man.WorkingPath,            "Valid100Lines.txt");
            string ValidNoNames = Path.Combine(man.WorkingPath,             "ValidNoNames.txt");

            /************************************************************************************/

            using (var conn = man.DbClient.GetConnection())
            {
                if (!DataClient.HasTable(conn, man.DbClient, "columnMappings"))
                {
                    if (!man.CreateColumnMappingsTable(conn))
                    {
                        Assert.Fail("Could not import sequence files");
                    }
                }

                /* Failures */
                foreach (string file in invalidInputs)
                {
                    AssertFailedImport(file, man, conn);
                }

                /* Successes */
                DataTable dt = null;

                //105 should really be 100, but there are duplicate rows in columnMappings
                //See http://192.168.1.2/FogBugz/default.asp?19869
                //If/when that bug gets fixed, 105 should be changed to 100 and this comment deleted
                Assert.IsTrue(File.Exists(Valid100Lines), "Could not find test file " + Valid100Lines);
                man.DesiredVariablesFilename = Valid100Lines;
                dt = man.GetRequestedVariables(conn);
                Assert.AreEqual(105, dt.Rows.Count,
                    "Unexpected number of rows returned for file " + Valid100Lines);

                
                Assert.IsTrue(File.Exists(ValidNoNames), "Could not find test file " + ValidNoNames);
                man.DesiredVariablesFilename = ValidNoNames;
                dt = man.GetRequestedVariables(conn);
                Assert.AreEqual(105, dt.Rows.Count,  
                    "Unexpected number of rows returned for file " + ValidNoNames);
            }
        }

        private void AssertFailedImport(string filename, AcsDataManager man, DbConnection conn)
        {
            Assert.IsTrue(File.Exists(filename), "Could not find test file " + filename);
            man.DesiredVariablesFilename = filename;

            DataTable dt = man.GetRequestedVariables(conn);
            Assert.IsTrue(dt == null, "Non-null DataTable returned for file " + filename);
        }

        //private List<string> GetParsingLog(string columnFile)
        //{
        //    var man = GetManager();

        //    var appender = new log4net.Appender.MemoryAppender();
        //    var mylog = (LogManager.GetLogger(man.GetType()).Logger as log4net.Repository.Hierarchy.Logger);
        //    mylog.AddAppender(appender);

        //    string oldName = man.DesiredVariablesFilename;
        //    man.DesiredVariablesFilename = columnFile;
        //    using (var conn = man.DbClient.GetConnection())
        //    {
        //        man.GetRequestedVariables(conn);
        //    }

        //    var events = appender.GetEvents();
        //    var result = new List<string>(events.Length);

        //    foreach (var e in events)
        //    {
        //        result.Add(e.RenderedMessage);
        //    }

        //    appender.Close();
        //    mylog.RemoveAppender(appender);
        //    man.DesiredVariablesFilename = oldName;

        //    return result;
        //}


        /// <summary>        
        /// Test to ensure importer correctly detects and bails on too many requested columns        
        /// </summary>        
        [Test]
        public void CheckTooManyColumnsFail()
        {
            string basePath = FileUtilities.PathEnsure(WorkingPath, "TestData");
            string TooManyVariablesFile = Path.Combine(basePath, "TooManyColumns.txt");

            if (!File.Exists(TooManyVariablesFile))
            {
                int maxColumns = 255, max = (maxColumns / 2) + 1;
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < max; i++)
                {
                    sb.Append("COLUMN").Append(i).Append(Environment.NewLine);
                }
                File.WriteAllText(TooManyVariablesFile, sb.ToString());
            }

            var manager = new AcsDataManager(AcsState.Wyoming);
            manager.WorkingPath = basePath;
            manager.DesiredVariablesFilename = TooManyVariablesFile;
            Assert.IsFalse(manager.CheckBuildVariableTable("TestTooMany"));
        }


        protected AcsDataManager GetManager()
        {
            AcsDataManager m = new AcsDataManager(AcsState.Wyoming);            
            m.WorkingPath = FileUtilities.PathEnsure(WorkingPath, "TestData");

            string dbPath = FileUtilities.PathEnsure(m.WorkingPath, "database");
            m.DBFilename = FileUtilities.PathCombine(dbPath, Settings.CurrentAcsDirectory + ".sqlite");

            m.ShapePath = FileUtilities.PathEnsure(m.WorkingPath, "shapes");
            m.CurrentDataPath = m.WorkingPath;

            //man.DataPath = FileLocator.GetStateBlockGroupDataDir(man.State);            
            //man.ShpPath = FileLocator.GetStateBlockGroupDataDir(man.State);                        
            //man.DBPath = FileUtilities.PathCombine(man.DataPath, man.State.ToString() + ".sqlite");

            m.DbClient = DataClient.GetDefaultClient(m.DBFilename);

            return m;
        }


        protected string GetShapePath(AcsDataManager man, string filename)
        {
            return Path.Combine(man.ShapePath, Path.GetFileName(filename));
        }
    }
}
