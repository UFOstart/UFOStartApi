﻿using System;
using System.Collections.Generic;
using System.Xml.Serialization;

namespace Model
{
    [Serializable]
    public class Round
    {
        [XmlAttribute]
        public string start { get; set; }

        [XmlAttribute]
        public string token { get; set; }

        [XmlElement (ElementName = "Needs")]
        public List<Need> Needs { get; set; }

    }
}
