﻿using System;
using System.Collections.Generic;
using System.Xml.Serialization;

namespace UFOStart.LinkedIn
{

    [Serializable]
    [XmlRoot("people-search")]
    public class PeopleSeach
    {
        [XmlElement(ElementName = "people")]
        public People People { get; set; }
    }


    [Serializable]
    public class People
    {
        [XmlElement(ElementName = "person")]
        public List<Person> Person { get; set; }

    }

    [Serializable]
    [XmlRoot("person")]
    public class Person
    {
        [XmlIgnore]
        public string id
        {
            get { return ID.value; }
            set { }
        }

        [XmlIgnore]
        public string firstName
        {
            get { return FirstName.value; }
            set { }
        }

        [XmlIgnore]
        public string lastName
        {
            get { return LastName.value; }
            set { }
        }

        [XmlIgnore]
        public string relation
        {
            get { return RelationToViewer.Distance.value; }
            set { }
        }


        [XmlIgnore]
        public string headline
        {
            get { return HeadLine.value; }
            set { }
        }

        [XmlIgnore]
        public string specialties
        {
            get { return Specialties.value; }
            set { }
        }

        [XmlIgnore]
        public string summary
        {
            get { return Summary.value; }
            set { }
        }

        [XmlIgnore]
        public string picture
        {
            get
            {
                if (Picture != null) return Picture.value;
                return "";
            }
            set { }
        }

        [XmlIgnore]
        public Person Intro
        {
            get { return RelationToViewer.Connections.Persons[0]; }

        }

        [XmlElement(ElementName = "id")]
        public ID ID { get; set; }

        [XmlElement(ElementName = "first-name")]
        public FirstName FirstName { get; set; }

        [XmlElement(ElementName = "last-name")]
        public LastName LastName { get; set; }

        [XmlElement(ElementName = "relation-to-viewer")]
        public RelationToViewer RelationToViewer { get; set; }

        [XmlElement(ElementName = "headline")]
        public HeadLine HeadLine { get; set; }

        [XmlElement(ElementName = "specialties")]
        public Specialties Specialties { get; set; }

        [XmlElement(ElementName = "summary")]
        public Summary Summary { get; set; }

        [XmlElement(ElementName = "industry")]
        public Industry Industry { get; set; }

        [XmlElement(ElementName = "picture-url")]
        public Picture Picture { get; set; }

        [XmlIgnore]
        public int rating { get; set; }
    }

    [Serializable]
        public class ID
        {
            [XmlText]
            public string value { get; set; }
        }

        [Serializable]
        public class FirstName
        {
            [XmlText]
            public string value { get; set; }
        }

        [Serializable]
        public class LastName
        {
            [XmlText]
            public string value { get; set; }
        }

        [Serializable]
        public class RelationToViewer
        {
            [XmlElement(ElementName = "distance")]
            public Distance Distance { get; set; }

            [XmlElement(ElementName = "related-connections")]
            public Connections Connections { get; set; }


        }

        [Serializable]
        public class Connections
        {
            [XmlElement(ElementName = "person")]
            public List<Person> Persons { get; set; }
        }

        [Serializable]
        public class Distance
        {
            [XmlText]
            public string value { get; set; }
        }


        [Serializable]
        public class HeadLine
        {
            [XmlText]
            public string value { get; set; }
        }

        [Serializable]
        public class Specialties
        {
            [XmlText]
            public string value { get; set; }
        }

        [Serializable]
        public class Summary
        {
            [XmlText]
            public string value { get; set; }
        }

        [Serializable]
        public class Industry
        {
            [XmlText]
            public string value { get; set; }
        }

        [Serializable]
        public class Picture
        {
            [XmlText]
            public string value { get; set; }
        }
    }
