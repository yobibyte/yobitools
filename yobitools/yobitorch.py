"""Useful utils for working with pytorch"""

def get_model_size(model):
    """get number of parameters in a pytorch module"""
    return sum(p.numel() for p in model.parameters() if p.requires_grad)
 

