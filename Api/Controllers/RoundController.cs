﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using HackandCraft.Api;
using HackandCraft.Config;
using Model;
using UFOStart.Model;

namespace UFOStart.Api.Controllers
{
    public class RoundController : HackandCraftController
    {
      
        public string create(Company company)
        {
            try
            {
                var myResult = orm.execObject<Result>(company, "api.company_round_create");
                var t = new Task(() => new FulfilRound(myResult.Round).fulfil());
                t.Start();
                result = orm.execObject<Result>(myResult.Round, "api.company_get_round");
                
            }
            catch (Exception exp)
            {
                errorResult(exp);
            }
            return formattedResult(result);
        }

        public string index(Round round)
        {
            try
            {
                result = orm.execObject<Result>(round, "api.company_get_round");
                
            }
            catch (Exception exp)
            {
                errorResult(exp);
            }
            return formattedResult(result);
        }

    }
}
