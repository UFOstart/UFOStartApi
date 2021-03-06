﻿using System;
using System.Collections.Generic;
using System.Xml;
using Model;
using UFOStart.LinkedIn;
using NLog;


namespace LinkedIn
{
public static class Contact
    {

    private static readonly LinkedInApi api = new LinkedInApi();
    public static readonly Logger log = LogManager.GetCurrentClassLogger();
    

    public static string getPicture(string id, string accessToken)
    {
        log.Warn("calling getPicture");
        if (id == "private") return null;
        var url =
            string.Format(
                "https://api.linkedin.com/v1/people/id={0}:(id,headline,first-name,last-name,specialties,summary,industry,picture-url)?oauth2_access_token={1}", id, accessToken);
        var contact = api.hit(url);
        var xml = new XmlDocument();
        xml.LoadXml(contact);
        var contactObj = api.deserialise(xml, new Person());
        return contactObj.picture;
    }


    public static List<string> getSkils(string id, string accessToken)
    {
        log.Warn("calling getSkils");
        if (id == "private") return null;
        var url =
            string.Format(
                "https://api.linkedin.com/v1/people/id={0}:(id,skills)?oauth2_access_token={1}", id, accessToken);
        var contact = api.hit(url);
        if (contact == null) return null;
        var xml = new XmlDocument();
        xml.LoadXml(contact);
        var contactObj = api.deserialise(xml, new Person());
        return contactObj.skillTags;
    }

    public static string getHeadline(string id, string accessToken)
    {
        try
        {
            log.Warn("calling getHeadline");
            if (id == "private") return null;
            var url =
                string.Format(
                    "https://api.linkedin.com/v1/people/id={0}:(id,headline)?oauth2_access_token={1}", id, accessToken);
            var contact = api.hit(url);
            var xml = new XmlDocument();
            xml.LoadXml(contact);
            var contactObj = api.deserialise(xml, new Person());
            return contactObj.headline;
        }
        catch (Exception exp)
        {
            throw;
        }
    }

    public static PeopleSeach getContacts(string keyword, string accessToken)
    {
        try
        {
            log.Warn("calling getContacts");
            var url =
                string.Format(
                    "https://api.linkedin.com/v1/people-search:(people:(id,skills,relation-to-viewer,headline,first-name,last-name,specialties,summary,industry,picture-url),num-results)?keywords={0}&count=25&sort=relevance&oauth2_access_token={1}",
                    keyword, accessToken);
            var contacts = api.hit(url);
            if (contacts == null)
                return null;
            var xml = new XmlDocument();
            xml.LoadXml(contacts);
            return api.deserialise(xml, new PeopleSeach());
        }
        catch (Exception exp)
        {
            throw;
        }

    }

    public static Person getIntro(Person person, string accessToken)
    {
        try
        {
            log.Warn("calling getIntro");
            if (person.id == "private") return null;
            var url =
                string.Format(
                    "https://api.linkedin.com/v1/people/id={0}:(id,headline,first-name,last-name,specialties,summary,industry,picture-url,relation-to-viewer:(related-connections))?oauth2_access_token={1}", person.id, accessToken);
            var contacts = api.hit(url);
            if (contacts == null)
                return null;
            var xml = new XmlDocument();
            xml.LoadXml(contacts);
            var intro = api.deserialise(xml, new Person());
            person.RelationToViewer.Connections = intro.RelationToViewer.Connections;
            return person;
        }
        catch (Exception exp)
        {
            throw;
        }
    }


    public static string getInterest(string id, string accessToken)
    {
        try
        {
            log.Warn("calling getInterest");
            if (id == "private") return null;
            var url =
                string.Format(
                    "https://api.linkedin.com/v1/people/id={0}:(id,interests)?oauth2_access_token={1}", id, accessToken);
            var personXml = api.hit(url);
            if (personXml == null)
                return null;
            var xml = new XmlDocument();
            xml.LoadXml(personXml);
            var person = api.deserialise(xml, new Person());
            return person.interests;
        }
        catch (Exception exp)
        {
            throw;
        }
    }


    public static Person getPerson(string id, string accessToken)
    {
        try
        {
            log.Warn("calling getPerson");
            if (id == "private") return null;
            var url =
                string.Format(
                    "https://api.linkedin.com/v1/people/id={0}:(id,headline,connections,positions,interests,skills,first-name,last-name,specialties,summary,industry,picture-url,relation-to-viewer:(related-connections))?oauth2_access_token={1}", id, accessToken);
            var personXml = api.hit(url);
            if (personXml == null)
                return null;
            var xml = new XmlDocument();
            xml.LoadXml(personXml);
            var person = api.deserialise(xml, new Person());
            return person;
        }
        catch (Exception exp)
        {
            throw;
        }
    }


    public static Connections getConnections(string id, string accessToken)
    {

        log.Warn("calling getConnections");
        if (id == "private") return null;
        
        var url =
            string.Format(
                "https://api.linkedin.com/v1/people/{0}/connections:(id)?oauth2_access_token={1}", id, accessToken);
        var contact = api.hit(url);
        var xml = new XmlDocument();
        xml.LoadXml(contact);
        var contactObj = api.deserialise(xml, new Connections());
        return contactObj;
    }

    }
}
