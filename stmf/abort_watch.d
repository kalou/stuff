#!/usr/sbin/dtrace -s
#pragma D option quiet

fbt:idm:idm_task_find_by_handle:entry 
{
    printf("%s is suboptimal\n", probename);
    stack();
}

sdt:stmf:stmf_abort:scsi-task-abort
{
    scsi_task = (scsi_task_t *) arg0;
    stmf_task = (stmf_i_scsi_task_t *)scsi_task->task_stmf_private;
    iscsit_task = (iscsit_task_t *) scsi_task->task_port_private;
    task = (idm_task_t *) iscsit_task->it_idm_task;

    working_stmf_task = stmf_task->itask_worker->worker_task_head;

    ip = (task->idt_ic->ic_raddr.ss_family == AF_INET) ?
        inet_ntoa((ipaddr_t *) &
                ((struct sockaddr_in *) &task->idt_ic->ic_raddr)->sin_addr) :
        inet_ntoa6(&((struct sockaddr_in6 *) &task->idt_ic->ic_raddr)->sin6_addr);
    port = ntohs(((struct sockaddr_in *) &task->idt_ic->ic_raddr)->sin_port);

	printf("Queue abort of %s%s%s task %lx (%x on %s:%d) after %d secs, queue time %d, accounted qtime %d, zfs time r/w %d/%d secs, network time r/w %d/%d secs -- task has %d cmds, timeout %d, expected xfer_len %d -- worker is %lx, has %d tasks in queue, handling task %lx (queue %d, acc %d, zfs %d/%d, net %d/%d), reason for abort is %d\n", 
        (task->idt_state == TASK_ABORTING) ? "aborting " : (task->idt_state == TASK_SUSPENDING) ? "suspending " : (task->idt_state == TASK_ACTIVE) ? "active " : (task->idt_state == TASK_IDLE) ? "idle " : "",
        scsi_task->task_flags & 0x40 ? "read" : "",
        scsi_task->task_flags & 0x20 ? "write" : "",
        (intptr_t) task, task->idt_client_handle, ip, port,
        (timestamp - stmf_task->itask_start_timestamp)/(1000*1000*1000),
        (timestamp - stmf_task->itask_waitq_enter_timestamp)/(1000*1000*1000),
        (stmf_task->itask_waitq_time)/(1000*1000*1000),
        (stmf_task->itask_lu_read_time)/(1000*1000*1000),
        (stmf_task->itask_lu_write_time)/(1000*1000*1000),
        (stmf_task->itask_lport_read_time)/(1000*1000*1000),
        (stmf_task->itask_lport_write_time)/(1000*1000*1000),
        (stmf_task->itask_ncmds),
        (scsi_task->task_timeout),
        scsi_task->task_expected_xfer_length,
        (intptr_t) stmf_task->itask_worker->worker_tid,
        stmf_task->itask_worker->worker_queue_depth,
        (intptr_t) stmf_task->itask_worker->worker_task_head,
        working_stmf_task ? (timestamp - working_stmf_task->itask_waitq_enter_timestamp)/(1000*1000*1000) : 0,
        working_stmf_task ? (working_stmf_task->itask_waitq_time)/(1000*1000*1000) : 0,
        working_stmf_task ? (working_stmf_task->itask_lu_read_time)/(1000*1000*1000) : 0,
        working_stmf_task ? (working_stmf_task->itask_lu_write_time)/(1000*1000*1000) : 0,
        working_stmf_task ? (working_stmf_task->itask_lport_read_time)/(1000*1000*1000) : 0,
        working_stmf_task ? (working_stmf_task->itask_lport_write_time)/(1000*1000*1000) : 0,
        arg1
    );

	stack();
}
