import unittest
from control_plane.model_router import choose_model,score_models

def rec(model,success,quality,rework=False,cost=.1,task_type="backend.python.api"):
    return {"task_type":task_type,"model":{"provider":"test","name":model},"result":{"success":success},"verification":{"reviewer_score":quality,"required_rework":rework},"execution":{"estimated_cost_usd":cost}}
class RouterTests(unittest.TestCase):
    def test_cold_start(self): self.assertIsNone(choose_model([rec("A",True,9)],"backend.python.api",3))
    def test_better_model_wins(self):
        rows=[rec("A",True,9.5),rec("A",True,9),rec("A",True,9.2),rec("B",True,7,True),rec("B",False,8,True),rec("B",True,7.5)]
        self.assertEqual(choose_model(rows,"backend.python.api",3).model,"A")
    def test_task_types_do_not_mix(self):
        rows=[rec("A",True,10,task_type="research") for _ in range(5)]+[rec("B",True,9) for _ in range(3)]
        self.assertEqual([r.model for r in score_models(rows,"backend.python.api",3)],["B"])
if __name__=="__main__": unittest.main()
