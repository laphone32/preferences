vim9script

export type EventFunctionType = func(): void
export def DummyEventFunction()
enddef

export class SeriesTimer
    var id: number
    var stages: list<dict<number>>
    var stage: number
    var OnData: EventFunctionType = DummyEventFunction

    def new(this.OnData = v:none)
    enddef

    def Start(stages: list<dict<number>>, onData = this.OnData)
        this.id = -1
        this.stages = stages->copy()
        this.stage = 0
        this.OnData = onData

        this._OnTime(this.id)
    enddef

    def _OnTime(id: number)
        this.OnData()
        var session = this.stages[this.stage]

        if session.repeat == -1
            this.id = timer_start(session.period, (_) => this.OnData(), { repeat: -1 })
        elseif session.repeat == 0
            if this.stage < len(this.stages) - 1
                this.stage += 1
                session = this.stages[this.stage]
                this.id = timer_start(session.period, this._OnTime, { repeat: session.repeat })
            endif
        elseif session.repeat > 0
            session.repeat -= 1
        endif
    enddef

    def Stop()
        this.id->timer_stop()
        this.stage = 0
        this.stages = null_list
    enddef
endclass

export class Timer
    var timer: SeriesTimer

    def new(onData = v:none)
        this.timer = SeriesTimer.new(onData)
    enddef

    def Start(period: number, repeat = -1)
        this.timer.Start([{
            period: period,
            repeat: repeat,
        }])
    enddef

    def Stop()
        this.timer.Stop()
    enddef

    def Restart(period: number, repeat = -1)
        this.Stop()
        this.Start(period, repeat)
    enddef
endclass

