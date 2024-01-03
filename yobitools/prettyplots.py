import matplotlib
import seaborn as sns
sns.set_style("darkgrid")


def wrap_axis(ax, title=None, x_label=None, y_label=None):
    if title is not None:
        ax.set_title(title, fontdict={'fontsize': 24})
    if x_label is not None:
        ax.set_xlabel(x_label, fontdict={'fontsize': 20})
    if y_label is not None:
        ax.set_ylabel(y_label, fontdict={'fontsize': 20})
    ax.xaxis.set_tick_params(labelsize=14)
    ax.yaxis.set_tick_params(labelsize=14)


