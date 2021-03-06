﻿using System;
using System.Collections.Generic;
using System.Xml.Serialization;
using UFOStart.Model;

namespace Model
{
    [Serializable]
    public class Expert
    {
        [XmlAttribute]
        public string linkedinId { get; set; }
        [XmlAttribute]
        public string firstName { get; set; }
        [XmlAttribute]
        public string lastName { get; set; }
        [XmlAttribute]
        public string picture { get; set; }
        [XmlAttribute]
        public string headline { get; set; }
        [XmlAttribute]
        public string introLinkedinId { get; set; }
        [XmlAttribute]
        public string introFirstName { get; set; }
        [XmlAttribute]
        public string introLastName { get; set; }
        [XmlAttribute]
        public string introPicture { get; set; }
        [XmlElement]
        public List<Skill> Skills { get; set; }

    }
}

