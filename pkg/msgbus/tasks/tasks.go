package tasks

import (
	"context"

	"kubegems.io/kubegems/pkg/apis/gems"
	"kubegems.io/kubegems/pkg/log"
	"kubegems.io/kubegems/pkg/msgbus/switcher"
	"kubegems.io/kubegems/pkg/service/handlers/application"
	"kubegems.io/kubegems/pkg/utils/msgbus"
	"kubegems.io/kubegems/pkg/utils/redis"
	"kubegems.io/kubegems/pkg/utils/retry"
	"kubegems.io/kubegems/pkg/utils/workflow"
)

type TaskProducer struct {
	Bus             *switcher.MessageSwitcher
	ApplicationTask *application.TaskProcessor
}

func RunTasksCollector(ctx context.Context, ms *switcher.MessageSwitcher, redis *redis.Client) error {
	task := &TaskProducer{
		Bus: ms,
		ApplicationTask: &application.TaskProcessor{
			Workflowcli: workflow.NewClientFromRedisClient(redis.Client),
		},
	}
	return task.Run(ctx)
}

func (p *TaskProducer) Run(ctx context.Context) error {
	return retry.Always(func() error {
		return p.runapplicationtasks(ctx)
	})
}

func (p *TaskProducer) runapplicationtasks(ctx context.Context) error {
	if err := p.ApplicationTask.WatchTasks(ctx, application.PathRef{}, "", func(_ context.Context, task *workflow.Task) error {
		// skip
		if len(task.Addtionals) == 0 {
			return nil
		}
		msg := &msgbus.NotifyMessage{
			MessageType: msgbus.Changed,
			EventKind:   msgbus.Update,
			InvolvedObject: &msgbus.InvolvedObject{
				Cluster: task.Addtionals[application.AnnotationCluster],
				Group:   gems.GroupName,
				Kind:    "Task",
				NamespacedName: msgbus.NamespacedNameFrom(
					task.Addtionals[application.AnnotationNamespace],
					task.Addtionals[application.LabelApplication],
				),
			},
			Content: task,
		}
		p.Bus.DispatchMessage(msg)
		return nil
	}); err != nil {
		log.Error(err, "task producer failed to watch")
		return err
	}
	return nil
}
